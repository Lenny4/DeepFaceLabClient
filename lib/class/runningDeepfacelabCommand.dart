import 'package:flutter/material.dart';

class RunningDeepfacelabCommand {
  RunningDeepfacelabCommand(
      {required this.key,
      required this.workspacePath,
      required this.condaProcess});

  String key;
  String? workspacePath;
  Widget condaProcess;
}
