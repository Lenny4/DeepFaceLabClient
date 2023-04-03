project init with: flutter create deepfacelab_client --platforms=linux,windows

flutter pub run build_runner watch --delete-conflicting-outputs

How can I extract a zip file archive in dart asynchronously?:

- https://stackoverflow.com/questions/52520744/how-can-i-extract-a-zip-file-archive-in-dart-asynchronously
- https://api.flutter.dev/flutter/foundation/compute-constant.html

https://azamsharp.medium.com/understanding-global-state-in-flutter-using-redux-2017b7646574

use: https://pub.dev/packages/file_picker#pick-a-directory

# https://github.com/nagadit/DeepFaceLab_Linux

Check latest cudnn and cudatoolkit version for your GPU device.
https://developer.nvidia.com/rdp/cudnn-archive
https://developer.nvidia.com/cuda-toolkit-archive
https://www.tensorflow.org/install/source#gpu
conda create [the name must contain python|cudnn|cudatoolkit version]
all libs versions: https://repo.anaconda.com/pkgs/main/linux-64/

conda init --verbose -d
conda init --reverse
conda env list
conda create -n deepfacelab -c main python=3.8 cudnn=8.2.1 cudatoolkit=11.3.1
conda activate deepfacelab
conda remove -n deepfacelab --all
