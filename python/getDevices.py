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

# conda init --verbose -d
# conda init --reverse
# conda env list
# conda create -n deepfacelab -c main python=3.8 cudnn=8.2.1 cudatoolkit=11.3.1
# conda activate deepfacelab
# conda remove -n deepfacelab --all

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/alexandre/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/alexandre/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/alexandre/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/alexandre/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
