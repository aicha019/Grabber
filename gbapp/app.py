from typing import Annotated, List
from fastapi import FastAPI, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlmodel import SQLModel, create_engine, Session, select
import json
import os
from models import Ordinateur, Employee, EmployeeOrdi, Partition
from forms import EmployeeForm

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# ===================== DATABASE =====================
#sqlite_url = "sqlite:///database.db"
#connect_args = {"check_same_thread": False}
#engine = create_engine(sqlite_url, connect_args=connect_args)

pg_url = (
f"postgresql+psycopg://"
f"{os.getenv('POSTGRES_USER')}:"
f"{os.getenv('POSTGRES_PASSWORD')}"
f"@db:5432/"
f"{os.getenv('POSTGRES_DB')}"
)
print(f"URL PGDB: {pg_url}")
engine = create_engine(pg_url)

SQLModel.metadata.create_all(engine)

# ===================== EMPLOYEE CREATE =====================
@app.get("/employee/create", response_class=HTMLResponse)
async def get_employee_form(request: Request):
    with Session(engine) as session:
        ordis = session.exec(select(Ordinateur)).all()
    return templates.TemplateResponse(
        "employee_form.html",
        {"request": request, "success": False, "ordis": ordis, "ordi_ids_selected": [], "is_edit": False}
    )

@app.post("/employee/create", response_class=RedirectResponse)
async def submit_employee_form(request: Request, data: Annotated[EmployeeForm, Form()]):
    with Session(engine) as session:
        employee = Employee(
            first_name=data.first_name,
            family_name=data.family_name,
            badge_number=data.badge_number
        )
        session.add(employee)
        session.commit()
        session.refresh(employee)

        if data.ordi_ids:
            for ordi_id in data.ordi_ids:
                lien = EmployeeOrdi(employee_id=employee.id, ordi_id=ordi_id)
                session.add(lien)
            session.commit()
    return RedirectResponse("/employees", status_code=303)


# ===================== LIST EMPLOYEES =====================
@app.get("/employees", response_class=HTMLResponse)
async def list_employees(request: Request):
    with Session(engine) as session:
        employees = session.exec(select(Employee)).all()
    return templates.TemplateResponse(
        "employees_list.html",
        {"request": request, "employees": employees}
    )


# ===================== EMPLOYEE EDIT =====================
@app.get("/employee/{employee_id}/edit", response_class=HTMLResponse)
async def edit_employee_form(request: Request, employee_id: int):
    with Session(engine) as session:
        employee = session.get(Employee, employee_id)
        if not employee:
            raise HTTPException(status_code=404, detail="Employé introuvable")
        ordis = session.exec(select(Ordinateur)).all()
        associations = session.exec(select(EmployeeOrdi).where(EmployeeOrdi.employee_id == employee_id)).all()
        ordi_ids_selected = [assoc.ordi_id for assoc in associations]
    return templates.TemplateResponse(
        "employee_form.html",
        {"request": request, "success": False, "employee": employee, "ordis": ordis,
         "ordi_ids_selected": ordi_ids_selected, "is_edit": True}
    )

@app.post("/employee/{employee_id}/edit", response_class=RedirectResponse)
async def submit_edit_employee(request: Request, employee_id: int, data: Annotated[EmployeeForm, Form()]):
    with Session(engine) as session:
        employee = session.get(Employee, employee_id)
        if employee is None:
            raise HTTPException(status_code=404, detail="Employé introuvable")
        
        employee.first_name = data.first_name
        employee.family_name = data.family_name
        employee.badge_number = data.badge_number

        # Supprimer les anciens liens
        old_liens = session.exec(select(EmployeeOrdi).where(EmployeeOrdi.employee_id == employee_id)).all()
        for lien in old_liens:
            session.delete(lien)

        # Ajouter les nouveaux liens
        if data.ordi_ids:
            for ordi_id in data.ordi_ids:
                lien = EmployeeOrdi(employee_id=employee_id, ordi_id=ordi_id)
                session.add(lien)

        session.commit()
    return RedirectResponse("/employees", status_code=303)



# ===================== LIST ORDI  =====================

@app.get("/ordis", response_class=HTMLResponse)
async def list_ordis(request: Request):
    with Session(engine) as session:
        ordis = session.exec(select(Ordinateur)).all()
    return templates.TemplateResponse(
        "ordis_list.html",
        {"request": request, "ordis": ordis}
    )


# ===================== ORDINATEUR INFO =====================
@app.get("/ordi/{ordi_id}", response_class=HTMLResponse)
async def get_ordi_info(request: Request, ordi_id: int):
    with Session(engine) as session:
        ordi = session.get(Ordinateur, ordi_id)
        if not ordi:
            raise HTTPException(status_code=404, detail="Ordinateur introuvable")
        partitions = session.exec(select(Partition).where(Partition.ordi_id == ordi_id)).all()
    return templates.TemplateResponse(
        "ordi.html",
        {"request": request, "ordi": ordi, "partitions": partitions}
    )


# ===================== DELETE ORDINATEUR =====================
@app.get("/ordi/{ordi_id}/delete")
async def delete_ordi(ordi_id: int):
    with Session(engine) as session:
        ordi = session.get(Ordinateur, ordi_id)
        if not ordi:
            raise HTTPException(status_code=404, detail="Ordinateur introuvable")
        partitions = session.exec(select(Partition).where(Partition.ordi_id == ordi_id)).all()
        for p in partitions:
            session.delete(p)
        session.delete(ordi)
        session.commit()
    return {"status": "deleted"}


# ===================== ENDPOINT POUR LE GRABBER =====================
@app.post("/endpoint")
async def receive_info(request: Request):
    try:
        data = await request.json()
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON")

    hardware = data.get("HARDWARE", {})
    software = data.get("SOFTWARE", {})
    partitions_data = hardware.get("partitions", [])

    with Session(engine) as session:
        #  Vérifie si l'ordi existe déjà via MAC
        ordi = session.exec(select(Ordinateur).where(Ordinateur.mac_adress == hardware.get("mac_adress", ""))).first()
        if ordi is None:
            ordi = Ordinateur(mac_adress=hardware.get("mac_adress", ""))
            session.add(ordi)
            session.commit()
            session.refresh(ordi)

        # ettre à jour toutes les infos de l'ordi
        for key, value in {
            "hostname": hardware.get("hostname", ""),
            "cpu_cores_number": hardware.get("cpu_cores_number", ""),
            "cpu_threads_number": hardware.get("cpu_threads_number", ""),
            "cpu_frequency_min": hardware.get("cpu_frequency_min", ""),
            "cpu_frequency_max": hardware.get("cpu_frequency_max", ""),
            "cpu_frequency_cur": hardware.get("cpu_frequency_cur", ""),
            "gpu_model": hardware.get("gpu_model", ""),
            "gpu_memory": hardware.get("gpu_memory", ""),
            "mb_serial": hardware.get("mb_serial", ""),
            "ram_size": hardware.get("ram_size", ""),
            "ram_number": hardware.get("ram_number", ""),
            "ram_slots_number": hardware.get("ram_slots_number", ""),
            "ram_0_frequence": hardware.get("ram_0_frequence", ""),
            "ram_0_slots": hardware.get("ram_0_slots", ""),
            "kernel": software.get("kernel", "")
        }.items():
            setattr(ordi, key, value)
        session.add(ordi)
        session.commit()
        session.refresh(ordi)


        old_partitions = session.exec(select(Partition).where(Partition.ordi_id == ordi.id)).all()
        for p in old_partitions:
            session.delete(p)
        session.commit()

        for p in partitions_data:
            partition = Partition(
                nom=p.get("nom", ""),
                fstype=p.get("fstype", ""),
                total_size=p.get("total_size", ""),
                used_space=p.get("used_space", ""),
                ordinateur=ordi
            )
            session.add(partition)
        session.commit()
        ordi_id = ordi.id  

    return {"status": "ok", "ordi_id": ordi_id}
