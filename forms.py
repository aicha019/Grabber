#!/usr/bin/python3

from pydantic import BaseModel

class EmployeeForm(BaseModel):
    first_name : str 
    family_name : str
    badge_number: str | None = None
    ordi_ids: list[int] | None = None
