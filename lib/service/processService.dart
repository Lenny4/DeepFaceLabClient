import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deepfacelab_client/class/condaEnvList.dart';
import 'package:flutter/cupertino.dart';

class ProcessService {
  Future<String> getCondaPrefix([ValueNotifier? ouputs]) async {
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
      if (ouputs != null) {
        ouputs.value = [
          ...ouputs.value,
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
        "${results?.join("\n") ?? ""} && \\ \n conda activate $condaEnvName";
    if (ouputs != null) {
      ouputs.value = [...ouputs.value, result];
    }
    return result;
  }
}
