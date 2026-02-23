#!/usr/bin/python3
import requests
from typing import List, Optional

from sqlmodel import SQLModel, Field, Relationship

# ===================== PARTITION =====================
class Partition(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    ordi_id: int | None = Field(default=None, foreign_key="ordinateur.id")
    nom: str
    fstype: str
    total_size: str
    used_space: str

    ordinateur: Optional["Ordinateur"] = Relationship(back_populates="partitions")

# ===================== RELATIONS =====================
class EmployeeOrdi(SQLModel, table=True):
    employee_id: int | None = Field(
        default=None, 
        foreign_key="employee.id", 
        primary_key=True
    )
    ordi_id: int | None = Field(
        default=None, 
        foreign_key="ordinateur.id",
        primary_key=True
    )

# ===================== EMPLOYEE =====================
class Employee(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    first_name: str = Field(index=True)
    family_name: str = Field(index=True)
    badge_number: str | None = Field(default=None, index=True)
    ordinateurs: list["Ordinateur"] = Relationship(
        back_populates="employees", 
        link_model=EmployeeOrdi
    )

# ===================== ORDINATEUR =====================
class Ordinateur(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True) 
    hostname: str | None = Field(default=None, index=True)
    mb_serial: str | None = Field(default=None, index=True)
    chassis_serial: str | None = Field(default=None, index=True)
    cpu: str | None = Field(default=None, index=True)
    cpu_id: str | None = Field(default=None, index=True)
    cpu_cores_number: str | None = Field(default=None, index=True)
    cpu_threads_number: str | None = Field(default=None, index=True) 
    cpu_frequency_min: str | None = Field(default=None, index=True)
    cpu_frequency_max: str | None = Field(default=None, index=True)
    cpu_frequency_cur: str | None = Field(default=None, index=True)
    gpu_model: str | None = Field(default=None, index=True)
    gpu_memory: str | None = Field(default=None, index=True)
    ram_slots_number: str | None = Field(default=None, index=True)
    mac_adress: str | None = Field(default=None, index=True, unique=True)
    ram_number: str | None = Field(default=None, index=True)
    ram_size: str | None = Field(default=None, index=True)
    ram_gen: str | None = Field(default=None, index=True)
    ram_0_size: str | None = Field(default=None, index=True)
    ram_0_frequence: str | None = Field(default=None, index=True)
    ram_0_slots: str | None = Field(default=None, index=True)
    ipv4: str | None = Field(default=None, index=True)
    routing: str | None = Field(default=None, index=True)

    os: str | None = Field(default=None, index=True)
    arch: str | None = Field(default=None, index=True)
    desktop: str | None = Field(default=None, index=True)
    wm: str | None = Field(default=None, index=True)
    kernel: str | None = Field(default=None, index=True)
    partitions: List[Partition] = Relationship(back_populates="ordinateur")

    employees: list["Employee"] = Relationship(
        back_populates="ordinateurs", 
        link_model=EmployeeOrdi
    )

    # ===================== MÉTHODES =====================
    def fetch_summary(self):
        return

    def shutdown(self):
        return

    def status(self):
        return

    def link_to_user(self, user):
        return

    def remove_user_access(self):
        return

    def show_users(self):
        return
