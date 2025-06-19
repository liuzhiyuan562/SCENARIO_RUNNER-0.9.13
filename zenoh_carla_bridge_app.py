from fastapi import FastAPI
from subprocess import Popen
import psutil

app = FastAPI()
bridge_process = None

@app.post("/start_bridge")
def start_bridge():
    global bridge_process
    if bridge_process and bridge_process.poll() is None:
        return {"message": "Bridge is already running."}
    bridge_process = Popen(["/home/zy/start_bridge.sh"])
    return {"message": "Bridge started."}

def kill_proc_tree(pid):
    try:
        parent = psutil.Process(pid)
        for child in parent.children(recursive=True):
            child.kill()
        parent.kill()
    except Exception as e:
        print(f"Error while killing process tree: {e}")

@app.post("/stop_bridge")
def stop_bridge():
    global bridge_process
    if bridge_process and bridge_process.poll() is None:
        kill_proc_tree(bridge_process.pid)
        bridge_process = None
        return {"message": "Bridge stopped."}
    return {"message": "Bridge is not running."}

@app.get("/status_bridge")
def status_bridge():
    global bridge_process
    if bridge_process and bridge_process.poll() is None:
        return {"status": "running"}
    else:
        return {"status": "not running"}
    