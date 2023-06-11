import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/conda_env_list.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:flutter/cupertino.dart';

class ProcessService {
  Future<String> getCondaPrefix(Workspace? workspace,
      {ValueNotifier<List<String>>? outputs}) async {
    if (Platform.isWindows) {
      return _getCondaPrefixWindows(outputs: outputs, workspace: workspace);
    }
    return _getCondaPrefixLinux(outputs: outputs, workspace: workspace);
  }

  static getRandomString() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(15, (index) => chars[Random().nextInt(chars.length)])
        .join();
  }

  Future<Map<String, String>> getCondaEnvironment(Workspace? workspace,
      {ValueNotifier<List<String>>? outputs}) async {
    String condaCommand =
        (await getCondaPrefix(workspace, outputs: outputs)).trim();
    var filePath =
        "${Platform.pathSeparator}ProgramData${Platform.pathSeparator}DeepFaceLabClient${Platform.pathSeparator}${getRandomString()}.bat";
    File file = await File(filePath).create(recursive: true);
    await file.writeAsString("""@echo off
$condaCommand""");
    var envVars = (await Process.run(filePath, [], runInShell: true))
        .stdout
        .toString()
        .split("\r\n")
        .map((e) => e.replaceAll(" ", ""))
        .where((element) => element != "")
        .toList();
    await file.delete();
    Map<String, String> result = {};
    for (var envVar in envVars) {
      var envVarSplit = envVar.split("=");
      result[envVarSplit[0]] = envVarSplit[1];
    }
    return result;
  }

  Future<String> _getCondaPrefixWindows(
      {ValueNotifier<List<String>>? outputs, Workspace? workspace}) async {
    var setEnv = File("${store.state.storage?.deepFaceLabFolder}/setenv.bat")
        .readAsStringSync()
        .replaceAll('SET INTERNAL=%~dp0',
            'SET INTERNAL=${store.state.storage?.deepFaceLabFolder}')
        .replaceAll('SET INTERNAL=%INTERNAL:~0,-1%', '');
    if (workspace != null) {
      setEnv = setEnv.replaceAll('SET WORKSPACE=%INTERNAL%\\..\\workspace',
          'SET WORKSPACE=${workspace.path}');
    }
    var envArr = setEnv
        .split("\r\n")
        .where((element) => element.trim() != '' && !element.startsWith('rem'))
        .toList();
    if (outputs != null) {
      outputs.value = [...outputs.value, envArr.join('\n')];
    }
    int envArrLength = envArr.length;
    for (var i = 0; i < envArrLength; i++) {
      String? match = RegExp(r'SET .*=').firstMatch(envArr[i])?.group(0);
      if (match != null) {
        match = match.replaceAll("SET ", "").replaceAll("=", "");
        envArr.add("echo $match=%$match%");
      }
    }
    return envArr.join('\n');
  }

  Future<String> _getCondaPrefixLinux(
      {ValueNotifier<List<String>>? outputs, Workspace? workspace}) async {
    String condaInit =
        (await Process.run('conda', ['init', '--verbose', '-d'])).stdout;
    String? match = RegExp(r'initialize[\s\S]*?initialize', multiLine: true)
        .firstMatch(condaInit)
        ?.group(0);
    Iterable<String>? results = match?.split('\n');
    results = results
        ?.where((e) => e.startsWith('+'))
        .map((e) => e.substring(1))
        .where((e) => e.startsWith('#') == false);
    // https://developer.nvidia.com/rdp/cudnn-archive
    // https://developer.nvidia.com/cuda-toolkit-archive
    // https://www.tensorflow.org/install/source#gpu
    // https://repo.anaconda.com/pkgs/main/linux-64/
    String pythonVersion = '3.7';
    String cudnnVersion = '7.6.5';
    String cudatoolkitVersion = '10.1.243';
    String condaEnvName =
        'deepFaceLabClient_python${pythonVersion}_cudnn${cudnnVersion}_cudatoolkit$cudatoolkitVersion';
    CondaEnvList condaEnvList = CondaEnvList.fromJson(jsonDecode(
        (await Process.run('conda', ['env', 'list', '--json'])).stdout));
    // https://stackoverflow.com/questions/59343470/type-dynamic-dynamic-is-not-a-subtype-of-type-dynamic-bool-of-tes
    // https://stackoverflow.com/questions/52354195/list-firstwhere-bad-state-no-element
    if (condaEnvList.envs.firstWhere((env) => env.contains(condaEnvName),
            orElse: () => "") ==
        "") {
      if (outputs != null) {
        outputs.value = [
          ...outputs.value,
          'conda create -n $condaEnvName -c main python=$pythonVersion cudnn=$cudnnVersion cudatoolkit=$cudatoolkitVersion'
        ];
      }
      (await Process.run('conda', [
        'create',
        '-n',
        condaEnvName,
        '-c',
        'main',
        'python=$pythonVersion',
        'cudnn=$cudnnVersion',
        'cudatoolkit=$cudatoolkitVersion'
      ]));
    }
    String result =
        "${results?.join("\n") ?? ""}\nconda activate $condaEnvName";
    if (outputs != null) {
      outputs.value = [...outputs.value, result];
    }
    return result.trim();
  }
}
