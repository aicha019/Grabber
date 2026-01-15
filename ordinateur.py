#!/usr/bin/python3
import configparser
import requests
class Ordinateur():
    CPU=""
    CPU_CORES_NUMBER = ""
    CPU_THREADS_NUMBER = ""
    CPU_FREQUENCY_MIN = ""
    CPU_FREQUENCY_MAX = ""
    CPU_FREQUENCY_CUR = ""
    MB_SERIAL = "" 
    GPU_MODEL = ""
    GPU_MEMORY = ""
    RAM = ""
    RAM_NUMBER = ""
    RAM_SLOTS_NUMBER = ""
    RAM_O_SIZE = ""
    RAM_O_FREQUENCE = ""
    RAM_O_SLOTS = ""

    OS = ""
    KERNEL = ""


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
