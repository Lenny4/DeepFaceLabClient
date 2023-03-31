# https://stackoverflow.com/questions/4383571/importing-files-from-different-folder#answer-4383597
import json
import sys

# caution: path[0] is reserved for script path (or '' in REPL)
sys.path.insert(1, '%deepFaceLabFolder%')

from core.leras.device import Devices

Devices.initialize_main_env()
all_devices = []
for device in Devices.getDevices():
    deviceJson = {}
    # https://stackoverflow.com/questions/25150955/python-iterating-through-object-attributes#answer-25151000
    for attr, value in device.__dict__.items():
        deviceJson[attr] = value
    all_devices.append(deviceJson)
all_devices.append({
    'index': 0,
    'tf_dev_type': 'tf_dev_type',
    'name': 'name',
    'total_mem': 3221225472,
    'total_mem_gb': 3221225472 / 1024 ** 3,
    'free_mem': 3221225472,
    'free_mem_gb': 3221225472 / 1024 ** 3,
})
print(json.dumps(all_devices), end='')
