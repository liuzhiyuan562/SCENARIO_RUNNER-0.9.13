import os
from fastapi import FastAPI,UploadFile, File, Form
from subprocess import Popen 
import psutil

app = FastAPI()
carla_process = None
scenario_process = None

@app.post("/start_carla")
def start_carla():
    global carla_process
    if carla_process and carla_process.poll() is None:
        return {"message": "CARLA is already running."}
    carla_process = Popen(["/home/carla/CarlaUE4.sh"])
    return {"message": "CARLA started."}

def kill_proc_tree(pid):
    try:
        parent = psutil.Process(pid)
        for child in parent.children(recursive=True):
            child.kill()
        parent.kill()
    except Exception as e:
        print(f"Error while killing process tree: {e}")

def terminate_proc_tree(pid, timeout=3):
    try:
        parent = psutil.Process(pid)
        children = parent.children(recursive=True)
        # 先尝试优雅终止所有子进程和父进程
        for child in children:
            child.terminate()
        parent.terminate()

        # 等待所有进程在 timeout 内退出
        gone, alive = psutil.wait_procs([parent] + children, timeout=timeout)
        if alive:
            # 超时后，强制kill还在的进程
            for p in alive:
                print(f"Force killing process {p.pid}")
                p.kill()
    except Exception as e:
        print(f"Error while terminating process tree: {e}")

@app.post("/stop_carla")
def stop_carla():
    global carla_process
    if carla_process and carla_process.poll() is None:
        kill_proc_tree(carla_process.pid)
        carla_process = None
        return {"message": "CARLA stopped."}
    return {"message": "CARLA is not running."}

@app.get("/status_carla")
def status_carla():
    global carla_process
    if carla_process and carla_process.poll() is None:
        return {"status": "running"}
    else:
        return {"status": "not running"}
    
@app.post("/upload_file")
async def upload_file(
    file: UploadFile = File(...),
    file_path: str = Form(...)
):
    save_path = os.path.expanduser(file_path)
    save_dir = os.path.dirname(save_path)
    os.makedirs(save_dir, exist_ok=True)

    try:
        with open(save_path, "wb") as f_out:
            while True:
                chunk = await file.read(1024 * 1024)
                if not chunk:
                    break
                f_out.write(chunk)
        return {"message": f"File {file.filename} saved to {save_path}"}
    except Exception as e:
        return {"error": str(e)}
    
@app.post("/start_scenario")
def start_scenario(
    scenario_name: str = Form(...),
):
    global scenario_process
    if scenario_process and scenario_process.poll() is None:
        return {"message": "Scenario generation is already running."}
    scenario_process = Popen(["python3", "/home/carla/scenario_runner-0.9.13/scenario_runner.py", "--scenario", scenario_name])
    return {"message": "Scenario generation started."}

@app.post("/stop_scenario")
def stop_scenario():
    global scenario_process
    if scenario_process and scenario_process.poll() is None:
        terminate_proc_tree(scenario_process.pid)
        scenario_process = None
        return {"message": "Scenario generation stopped."}
    return {"message": "Scenario generation is not running."}

@app.get("/status_scenario")
def status_scenario():
    global scenario_process
    if scenario_process and scenario_process.poll() is None:
        return {"status": "running"}
    else:
        return {"status": "not running"}
    
@app.post("/start_egovehicle")
def start_egovehicle():
    Popen(["python3", "/home/carla/zenoh_python_command/scenario_autoware.py"], cwd="/home/carla/zenoh_python_command")
    return {"message": "Ego vehicle started."}





