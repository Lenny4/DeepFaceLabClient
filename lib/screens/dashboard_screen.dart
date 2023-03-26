import 'dart:io';

import 'package:deepfacelab_client/widget/installation/installation_widget.dart';
import 'package:deepfacelab_client/widget/installation/requirement_linux_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardScreen extends HookWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (Platform.isLinux) RequirementLinuxWidget(),
          InstallationWidget(),
        ]),
      ),
    );
  }
}
