from typing import Annotated 

from fastapi import FastAPI, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from pydantic import BaseModel

from sqlmodel import SQLModel, create_engine, Session, select
import json 

from models import Ordinateur, Employee, EmployeeOrdi
from forms import EmployeeForm

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

sqlite_url = f"sqlite:///database.db"

connect_args = {"check_same_thread": False}
engine = create_engine(sqlite_url, connect_args=connect_args)

SQLModel.metadata.create_all(engine)


#ordi1 = Ordinateur()

@app.get("/employee/create", response_class=HTMLResponse)
async def get_employee_form(request: Request):
    with Session(engine) as session:
        ordis = session.exec(select(Ordinateur)).all()
    return templates.TemplateResponse(
        request=request,
        name="employee_form.html",
        context={"success": False, "ordis": ordis}
    )

@app.post("/employee/create", response_class=RedirectResponse)
async def submit_employee_form(request: Request, data: Annotated[EmployeeForm, Form()]):
    print(f"data obtained is {data}")
    with Session(engine) as session :
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

@app.get("/employees", response_class=HTMLResponse)
async def get_employees(request: Request):
    with Session(engine) as session:
        statement = select(Employee)
        employees = session.exec(statement).all() 

        return templates.TemplateResponse(
            request=request, name="employees.html",
                context={"employees": employees})


@app.get("/employee/{employee_id}/edit", response_class=HTMLResponse)
async def edit_employee_form(request: Request, employee_id: int):
    with Session(engine) as session:
        employee = session.get(Employee, employee_id)
        if employee is None:
            raise HTTPException(status_code=404, detail="Employé introuvable")
        ordis = session.exec(select(Ordinateur)).all()
        ordi_ids_lies = [o.id for o in employee.ordinateurs]
    return templates.TemplateResponse(
        request=request,
        name="employee_edit.html",
        context={"employee": employee, "ordis": ordis, "ordi_ids_lies": ordi_ids_lies}
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





@app.get("/ordi/{ordi_id}", response_class=HTMLResponse)
async def get_ordi1_info(request: Request, ordi_id: int):
    with Session(engine) as session: 
        statement = select(Ordinateur).where( Ordinateur.id == ordi_id )
        this_ordi = session.exec(statement).first() 

        return templates.TemplateResponse(
            request=request, name="ordi.html", context={"ordi": this_ordi}
        )

@app.get("/ordi/{ordi_id}/delete")
async def delete_ordi(request: Request, ordi_id: int):
    with Session(engine) as session:
        statement = select(Ordinateur).where(Ordinateur.id == ordi_id)
        ordi = session.exec(statement).first()
        if ordi is None:
            raise HTTPException(status_code=404, detail="Ordinateur introuvable")
        session.delete(ordi)
        session.commit()
    return {"status": "deleted"}

@app.post("/endpoint")
async def receive_info(request: Request):
    # Lire le body brut
    body = await request.body()
    print(body)

    # Parser le JSON
    try:
        data = json.loads(body)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON")
    
    # Debug
    print("Infos recues :", data)
    hardware = data.get("HARDWARE", {})
    
    with Session(engine) as session:
        statement = select(Ordinateur).where( Ordinateur.mac_adress == hardware.get('mac_adress', ""))
        ordi_exists = session.exec(statement).first()

        if ordi_exists is None:
            ordi1 = Ordinateur()
        else:
            ordi1 = ordi_exists
        ordi1.hostname = hardware.get("hostname", "")
        ordi1.cpu_cores_number = hardware.get('cpu_cores_number', "")
        ordi1.cpu_threads_number = hardware.get('cpu_threads_number', "")
        ordi1.cpu_frequency_min = hardware.get('cpu_frequency_min', "")
        ordi1.cpu_frequency_max = hardware.get('cpu_frequency_max', "")
        ordi1.cpu_frequency_cur = hardware.get('cpu_frequency_cur', "")

        ordi1.gpu_model = hardware.get('gpu_model', "")
        ordi1.gpu_memory = hardware.get('gpu_memory', "")
        ordi1.mac_adress = hardware.get('mac_adress', "")
        ordi1.mb_serial = hardware.get('mb_serial', "")

        ordi1.ram_size = hardware.get('ram_size', "")
        ordi1.ram_number = hardware.get('ram_number', "")
        ordi1.ram_slots_number = hardware.get('ram_slots_number', "")

        #ordi1.ram_0_size = hardware.get('ram_0_size', "")
        ordi1.ram_0_frequence = hardware.get('ram_0_frequence', "")
        ordi1.ram_0_slots = hardware.get('ram_0_slots', "")

        software = data.get("SOFTWARE", {})
        ordi1.kernel = software.get('kernel', "")
        print(f"Le hostname de l'ordi est {ordi1.hostname}")
        print(f"Le serial de la mb est {ordi1.mb_serial}")

        session.add(ordi1)
        session.commit()

    return {"status": "ok"}


