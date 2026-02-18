#!/usr/bin/python3
import configparser
import requests

from sqlmodel import SQLModel, Field, Relationship

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


class Employee(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    first_name: str = Field(index=True)
    family_name: str = Field(index=True)
    badge_number: str | None = Field(default=None, index=True)
    ordinateurs: list["Ordinateur"] = Relationship(back_populates="employees", link_model=EmployeeOrdi)

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

    employees: list["Employee"] = Relationship(back_populates="ordinateurs", link_model=EmployeeOrdi)

    '''
    def __init__(self):
        self.reload()
    def reload(self):
        r = requests.get("http://localhost:8000/summary.txt")
        r.raise_for_status()
        print(type(r.content.decode("utf-8")))
        sum = configparser.ConfigParser()
        sum.read_string(r.content.decode("utf-8"))
        # sum.read("/opt/grabber/summary.txt")
        if "CPU" in sum['HARDWARE']:
            self.CPU = sum['HARDWARE']['CPU']
        if "CPU_CORES_NUMBER" in sum['HARDWARE']:
            self.CPU_CORES_NUMBER = sum['HARDWARE']['CPU_CORES_NUMBER']
        if "RAM" in sum['HARDWARE']:
            self.RAM = sum['HARDWARE']['RAM']
        if "MB_SERIAL" in sum['HARDWARE']:
            self.MB_SERIAL =sum['HARDWARE']['MB_SERIAL']
        if "CPU_THREADS_NUMBER" in sum['HARDWARE']:
            self.CPU_THREADS_NUMBER =sum['HARDWARE']['CPU_THREADS_NUMBER']
        if "CPU_FREQUENCY_MIN" in sum['HARDWARE']:
            self.CPU_FREQUENCY_MIN =sum['HARDWARE']['CPU_FREQUENCY_MIN']
        if "CPU_FREQUENCY_CUR" in sum['HARDWARE']:
            self.CPU_FREQUENCY_CUR=sum['HARDWARE']['CPU_FREQUENCY_CUR']
        if "CPU_FREQUENCY_MAX" in sum['HARDWARE']:
            self.CPU_FREQUENCY_MAX=sum['HARDWARE']['CPU_FREQUENCY_MAX']
        if "GPU_MODEL" in sum['HARDWARE']:
            self.GPU_MODEL = sum['HARDWARE']['GPU_MODEL']
        if "GPU_MEMORY" in sum['HARDWARE']:
            self.GPU_MEMORY = sum['HARDWARE']['GPU_MEMORY']
        if "RAM_SLOTS_NUMBER" in sum['HARDWARE']:
            self.RAM_SLOTS_NUMBER = sum['HARDWARE']['RAM_SLOTS_NUMBER']
        if "RAM_NUMBER" in sum['HARDWARE']:
            self.RAM_NUMBER=sum['HARDWARE']['RAM_NUMBER']
        if "RAM_0_SIZE" in sum['HARDWARE']:
            self.RAM_0_SIZE=sum['HARDWARE']['RAM_0_SIZE']
        if "OS" in sum['SOFTWARE']:
            self.OS = sum['SOFTWARE']['OS']
        if "KERNEL" in sum['SOFTWARE']:
            self.KERNEL = sum['SOFTWARE']['KERNEL']
        return
    '''
    def fetch_summary(self):
        return
    def shutdown():
        return
    def status(self):
        return
    def link_to_user(self,user):
        return
    def remove_user_access(self):
        return
    def show_users(self):
        return
