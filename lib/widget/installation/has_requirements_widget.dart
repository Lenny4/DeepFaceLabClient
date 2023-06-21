import 'dart:io';

import 'package:deepfacelab_client/widget/installation/installation_widget.dart';
import 'package:deepfacelab_client/widget/installation/requirement_linux_widget.dart';
import 'package:deepfacelab_client/widget/installation/requirement_windows_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HasRequirementsWidget extends HookWidget {
  const HasRequirementsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (Platform.isLinux) ...[
        RequirementLinuxWidget(),
      ],
      if (Platform.isWindows) ...[
        const RequirementWindowsWidget(),
      ],
      InstallationWidget(),
    ]);
  }
}
