import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _FileManagerLinuxWidget extends HookWidget {
  _FileManagerLinuxWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("FileManagerLinuxWidget");
  }
}

class _FileManagerWindowsWidget extends HookWidget {
  _FileManagerWindowsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("FileManagerWindowsWidget");
  }
}

class FileManagerWidget extends HookWidget {
  FileManagerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isLinux
        ? _FileManagerLinuxWidget()
        : _FileManagerWindowsWidget();
  }
}
