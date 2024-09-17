import json
import sys

# caution: path[0] is reserved for script path (or '' in REPL)
sys.path.insert(1, '%deepFaceLabFolder%')

from core.leras.device import Devices

# Initialize the environment
Devices.initialize_main_env()

all_devices = []
try:
    for device in Devices.getDevices():
        deviceJson = {attr: value for attr, value in device.__dict__.items()}
        all_devices.append(deviceJson)
except Exception as e:
    print(f"An error occurred: {e}", file=sys.stderr)

# Convert device data to JSON format and print it
print(json.dumps(all_devices), end='')
