project init with: flutter create deepfacelab_client --platforms=linux,windows

flutter pub run build_runner watch --delete-conflicting-outputs

How can I extract a zip file archive in dart asynchronously?:

- https://stackoverflow.com/questions/52520744/how-can-i-extract-a-zip-file-archive-in-dart-asynchronously
- https://api.flutter.dev/flutter/foundation/compute-constant.html

# https://github.com/nagadit/DeepFaceLab_Linux

conda init --verbose -d
conda init --reverse
conda env list
conda create -n deepfacelab -c main python=3.8 cudnn=8.2.1 cudatoolkit=11.3.1
conda activate deepfacelab
conda remove -n deepfacelab --all

TODO: desktop_drop