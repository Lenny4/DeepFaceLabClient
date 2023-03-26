project init with: flutter create deepfacelab_client --platforms=linux,windows

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


var process = await Process.start('pkexec', ['bash', '-c', "pwd && ls -al"]);
process.stdout.transform(utf8.decoder).forEach((String output) {
print(output);
});
process.stderr.transform(utf8.decoder).forEach((String output) {
print(output);
});
process.exitCode.then((value) {
print("$value okok");
});

String homeDirectory = (Platform.environment)['HOME'] ?? "/";
