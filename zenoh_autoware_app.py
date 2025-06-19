import os
from fastapi import FastAPI,Form
from subprocess import Popen
import psutil

app = FastAPI()
autoware_process = None

@app.post("/start_autoware")
def start_autoware(
    vehicle_name: str = Form("hero")
):
    global autoware_process
    if autoware_process and autoware_process.poll() is None:
        return {"message": "Autoware is already running."}
    autoware_process = Popen(["/home/zy/start_autoware.sh",vehicle_name])
    return {"message": "Autoware started."}

def kill_proc_tree(pid):
    try:
        parent = psutil.Process(pid)
        for child in parent.children(recursive=True):
            child.kill()
        parent.kill()
    except Exception as e:
        print(f"Error while killing process tree: {e}")

@app.post("/stop_autoware")
def stop_autoware():
    global autoware_process
    if autoware_process and autoware_process.poll() is None:
        kill_proc_tree(autoware_process.pid)
        autoware_process = None
        return {"message": "Autoware stopped."}
    return {"message": "Autoware is not running."}

@app.get("/status_autoware")
def status_autoware():
    global autoware_process
    if autoware_process and autoware_process.poll() is None:
        return {"status": "running"}
    else:
        return {"status": "not running"}