import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deepfacelab_client/class/device.dart';
import 'package:deepfacelab_client/service/processService.dart';
import 'package:redux/redux.dart';

class PythonService {
  Future<String> _getPythonScript(String filename) async {
    return (await (File(
            ((await Process.run("pwd", [])).stdout + "/python/" + filename)
                .replaceAll("\n", "")))
        .readAsString());
  }

  Future<List<Device>> getDevices(Store store) async {
    await ProcessService().getCondaPrefix();
    String pythonScript = (await _getPythonScript("getDevices.py")).replaceAll(
        '%deepFaceLabFolder%', store.state.storage.deepFaceLabFolder);
    ProcessResult result = await Process.run("bash", [
      '-c',
      """${await ProcessService().getCondaPrefix()} && \\
      echo -e "$pythonScript" | python"""
    ]);
    return (jsonDecode(result.stdout) as List<dynamic>)
        .map((e) => Device.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
