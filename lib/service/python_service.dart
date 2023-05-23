import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/device.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/process_service.dart';

class PythonService {
  Future<String> _getPythonScript(String filename) async {
    return (await (File(
            ("${Directory.current.path}${Platform.pathSeparator}python${Platform.pathSeparator}$filename")
                .replaceAll("\n", "")))
        .readAsString());
  }

  updateDevices(Workspace? workspace) async {
    if (store.state.devices != null ||
        store.state.hasRequirements != true ||
        store.state.storage?.deepFaceLabFolder == null) {
      return;
    }
    var condaPrefix = await ProcessService().getCondaPrefix(workspace);
    String deepFaceLabFolder =
        store.state.storage?.deepFaceLabFolder ?? Platform.pathSeparator;
    String pythonScript = "";
    if (Platform.isWindows) {
      deepFaceLabFolder = "$deepFaceLabFolder\\DeepFaceLab".replaceAll("\\", "\\\\");
      pythonScript = (await _getPythonScript("getDevices.py"));
      pythonScript = pythonScript
          .replaceAll("%deepFaceLabFolder%", deepFaceLabFolder);
    } else {
      pythonScript = (await _getPythonScript("getDevices.py"))
          .replaceAll('%deepFaceLabFolder%', deepFaceLabFolder);
    }
    ProcessResult result;
    if (Platform.isWindows) {
      // https://stackoverflow.com/a/35651859/6824121
      result = await Process.run(
          "C:\\Users\\alexa\\Downloads\\_internal\\python-3.6.8\\python.exe",
          ['-c', 'exec(r"""$pythonScript""")']);
    } else {
      // https://stackoverflow.com/a/2043499/6824121
      result = await Process.run("bash", [
        '-c',
        """$condaPrefix && \\
      echo -e "$pythonScript" | python"""
      ]);
    }
    store.dispatch({
      'devices': (jsonDecode(result.stdout) as List<dynamic>)
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList()
    });
  }
}
