import socket
import urllib.request
import subprocess

def get_wifi_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        pass
    
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return "127.0.0.1"

def check_adb_status():
    try:
        res = subprocess.run(["adb", "devices"], capture_output=True, text=True, timeout=3)
        devices = [line.split()[0] for line in res.stdout.strip().splitlines()[1:] if "device" in line]
        if devices:
            # Auto-apply port forwarding
            subprocess.run(["adb", "reverse", "tcp:8000", "tcp:8000"], capture_output=True, timeout=3)
            return True, devices
    except Exception:
        pass
    return False, []

def check_server_live():
    try:
        req = urllib.request.urlopen("http://127.0.0.1:8000/health", timeout=2)
        return req.status == 200
    except Exception:
        return False

def main():
    wifi_ip = get_wifi_ip()
    adb_connected, devices = check_adb_status()
    is_live = check_server_live()

    print("=" * 65)
    print("           AGRIVYN SMART FARMING - SERVER URL GENERATOR")
    print("=" * 65)
    print(f" Server Status:     {'[ONLINE - HEALTHY]' if is_live else '[OFFLINE - Run: python main.py]'}")
    print(f" Active Wi-Fi IP:   {wifi_ip}")
    if adb_connected:
        print(f" USB Phone Device:  [CONNECTED: {', '.join(devices)}] (Port 8000 reversed)")
    print("-" * 65)
    print(" CONNECTION URLS FOR DIFFERENT CLIENTS:")
    print("-" * 65)
    print(f" 1. Physical Phone (USB Cable):   http://127.0.0.1:8000/api")
    print(f" 2. Physical Phone (Wi-Fi):       http://{wifi_ip}:8000/api")
    print(f" 3. Android Emulator:             http://10.0.2.2:8000/api")
    print(f" 4. PC Web Browser / App:         http://localhost:8000/app")
    print(f" 5. Admin & Village Portal:       http://localhost:8000/admin")
    print(f" 6. Interactive Swagger Docs:     http://localhost:8000/docs")
    print("=" * 65)
    print(" Tip: In Flutter App -> Settings -> Server URL, paste either (1) or (2).")
    print("=" * 65)

if __name__ == "__main__":
    main()
