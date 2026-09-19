"""
AgriVyn - Start Backend with ngrok Tunnel
Starts FastAPI server + ngrok tunnel and updates .env with the live public URL.
Run this script ONCE before making Twilio calls.

Usage:  python start_voice_calls.py
"""
import os
import sys
import time
import requests
from pyngrok import ngrok

PROJECT_ROOT = r"d:\FLUTTER PROJECTS\AgriVyn"
ENV_FILE = os.path.join(PROJECT_ROOT, ".env")


def update_env_file(key, value):
    """Update a specific key in the .env file."""
    lines = []
    updated = False
    try:
        with open(ENV_FILE, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith(f"{key}="):
                    lines.append(f"{key}={value}\n")
                    updated = True
                else:
                    lines.append(line)
    except FileNotFoundError:
        lines = []

    if not updated:
        lines.append(f"{key}={value}\n")

    with open(ENV_FILE, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print(f"  Updated .env: {key}={value}")


def check_backend_running():
    try:
        r = requests.get("http://127.0.0.1:8000/api/telephony/config-status", timeout=3)
        return r.status_code == 200
    except Exception:
        return False


def main():
    print("=" * 60)
    print("  AgriVyn Voice Call Setup")
    print("=" * 60)

    # Step 1: Check if FastAPI is running
    print("\n[1] Checking FastAPI backend...")
    if check_backend_running():
        print("  OK - Backend running at http://127.0.0.1:8000")
    else:
        print("  NOT RUNNING! Please start the backend first:")
        print("    python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload")
        sys.exit(1)

    # Step 2: Start ngrok tunnel
    print("\n[2] Starting ngrok tunnel on port 8000...")
    tunnel = ngrok.connect(8000, 'http')
    public_url = tunnel.public_url
    if public_url.startswith('http://'):
        public_url = public_url.replace('http://', 'https://', 1)
    print(f"  Tunnel active: {public_url}")

    # Step 3: Update .env
    print("\n[3] Updating .env with active tunnel URL...")
    update_env_file("PUBLIC_SERVER_URL", public_url)

    # Step 4: Test the TwiML endpoint
    print("\n[4] Verifying TwiML webhook endpoint...")
    time.sleep(2)
    test_url = f"{public_url}/api/telephony/twiml/welcome?lang=ta&name=Test"
    try:
        r = requests.post(test_url, timeout=15)
        if r.status_code == 200:
            print(f"  OK - TwiML endpoint returns 200 and valid XML")
        else:
            print(f"  WARNING - Endpoint returned {r.status_code}")
    except Exception as e:
        print(f"  WARNING - Endpoint check failed: {e}")

    print("\n" + "=" * 60)
    print(f"  READY! Twilio will use: {public_url}")
    print(f"  Admin Dashboard: http://127.0.0.1:8000/admin/")
    print("=" * 60)
    print("\n  Keeping tunnel alive. Press Ctrl+C to stop.\n")

    try:
        while True:
            time.sleep(30)
    except KeyboardInterrupt:
        print("\n  Stopping...")
        ngrok.disconnect(tunnel.public_url)
        ngrok.kill()
        print("  Done.")


if __name__ == "__main__":
    main()
