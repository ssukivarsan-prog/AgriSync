"""
AgriVyn Stable Tunnel + Backend Launcher.
Starts ngrok tunnel then keeps it alive with a heartbeat.
"""
import time
import threading
import signal
import sys
import subprocess
import os

# ─── 1. Start backend server in background ───────────────────────────────────
print("[AgriVyn] Starting FastAPI backend on port 8000...")
backend = subprocess.Popen(
    [sys.executable, "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"],
    cwd=r"d:\FLUTTER PROJECTS\AgriVyn",
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
)
print(f"[AgriVyn] Backend PID: {backend.pid}")

# Wait for backend to be ready
import urllib.request
for attempt in range(30):
    try:
        with urllib.request.urlopen("http://127.0.0.1:8000/health", timeout=2) as r:
            if r.status == 200:
                print(f"[AgriVyn] Backend is UP after {attempt+1} attempts!")
                break
    except Exception:
        time.sleep(1)
else:
    print("[AgriVyn] WARNING: Backend may not be ready.")

# ─── 2. Start ngrok tunnel ───────────────────────────────────────────────────
from pyngrok import ngrok

print("[AgriVyn] Starting ngrok tunnel on port 8000...")
tunnel = ngrok.connect(8000, "http")
public_url = tunnel.public_url
if public_url.startswith("http://"):
    public_url = public_url.replace("http://", "https://", 1)
print(f"[AgriVyn] Tunnel URL: {public_url}")

# ─── 3. Update .env with confirmed public URL ────────────────────────────────
env_path = r"d:\FLUTTER PROJECTS\AgriVyn\.env"
with open(env_path, "r") as f:
    lines = f.readlines()

with open(env_path, "w") as f:
    for line in lines:
        if line.startswith("PUBLIC_SERVER_URL="):
            f.write(f"PUBLIC_SERVER_URL={public_url}\n")
        else:
            f.write(line)
print(f"[AgriVyn] Updated .env: PUBLIC_SERVER_URL={public_url}")

# ─── 4. Heartbeat: keep tunnel alive & verify TwiML endpoint ─────────────────
print(f"[AgriVyn] TwiML webhook: {public_url}/api/telephony/twiml/welcome?lang=ta&name=Farmer")
print("[AgriVyn] Running heartbeat every 30 seconds. Press Ctrl+C to stop.")

def heartbeat():
    while True:
        try:
            req = urllib.request.Request(
                f"{public_url}/health",
                headers={"ngrok-skip-browser-warning": "1"}
            )
            with urllib.request.urlopen(req, timeout=5) as r:
                status = "OK" if r.status == 200 else f"HTTP {r.status}"
        except Exception as e:
            status = f"UNREACHABLE: {e}"
        print(f"[AgriVyn][{time.strftime('%H:%M:%S')}] Tunnel health: {status}")
        time.sleep(30)

hb = threading.Thread(target=heartbeat, daemon=True)
hb.start()

# ─── 5. Keep running ─────────────────────────────────────────────────────────
def shutdown(sig, frame):
    print("\n[AgriVyn] Shutting down...")
    ngrok.disconnect(tunnel.public_url)
    ngrok.kill()
    backend.terminate()
    sys.exit(0)

signal.signal(signal.SIGINT, shutdown)
signal.signal(signal.SIGTERM, shutdown)

print("[AgriVyn] All systems running. Tunnel is live.")
while True:
    time.sleep(60)
