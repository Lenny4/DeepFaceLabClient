# https://stackoverflow.com/questions/4383571/importing-files-from-different-folder#answer-4383597
import sys

# caution: path[0] is reserved for script path (or '' in REPL)
sys.path.insert(1, '/home/alexandre/Documents/project/DeepFaceLab')

from core.leras.device import Devices

Devices.initialize_main_env()
all_devices = []
for device in Devices.getDevices():
    deviceJson = {}
    # https://stackoverflow.com/questions/25150955/python-iterating-through-object-attributes#answer-25151000
    for attr, value in device.__dict__.items():
        deviceJson[attr] = value
    all_devices.append(deviceJson)
print(all_devices)
