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
            ("${Directory.current.path}${Platform.pathSeparator}script${Platform.pathSeparator}python${Platform.pathSeparator}$filename")
                .replaceAll("\n", "")))
        .readAsString());
  }

  String getPythonExec([String? deepFaceLabFolder]) {
    if (Platform.isWindows) {
      deepFaceLabFolder ??=
          store.state.storage?.deepFaceLabFolder ?? Platform.pathSeparator;
      return "$deepFaceLabFolder\\python-3.6.8\\python.exe";
    }
    return 'python';
  }

  updateDevices(Workspace? workspace) async {
    if (store.state.devices != null ||
        store.state.hasRequirements != true ||
        store.state.storage?.deepFaceLabFolder == null) {
      return;
    }
    String deepFaceLabFolder =
        store.state.storage?.deepFaceLabFolder ?? Platform.pathSeparator;
    String pythonScript = "";
    if (Platform.isWindows) {
      deepFaceLabFolder = deepFaceLabFolder.replaceAll("\\", "\\\\");
      pythonScript = (await _getPythonScript("getDevices.py"));
      pythonScript = pythonScript.replaceAll(
          "%deepFaceLabFolder%", "$deepFaceLabFolder\\\\DeepFaceLab");
    } else {
      pythonScript = (await _getPythonScript("getDevices.py"))
          .replaceAll('%deepFaceLabFolder%', deepFaceLabFolder);
    }
    ProcessResult result;
    var pythonExec = getPythonExec(deepFaceLabFolder);
    if (Platform.isWindows) {
      // https://stackoverflow.com/a/35651859/6824121
      result =
          await Process.run(pythonExec, ['-c', 'exec(r"""$pythonScript""")'],
              environment: await ProcessService().getCondaEnvironment(workspace));
    } else {
      // https://stackoverflow.com/a/2043499/6824121
      result = await Process.run("bash", [
        '-c',
        """${await ProcessService().getCondaPrefix(workspace)} && \\
      echo -e "$pythonScript" | $pythonExec"""
      ]);
    }
    store.dispatch({
      'devices': (jsonDecode(result.stdout) as List<dynamic>)
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList()
    });
  }
}
