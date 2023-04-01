import 'package:deepfacelab_client/class/form/inputForm.dart';
import 'package:deepfacelab_client/class/form/workspaceForm.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WorkspaceFormWidget extends HookWidget {
  final Workspace? initWorkspace;

  const WorkspaceFormWidget({Key? key, this.initWorkspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var workspaceForm = useState<WorkspaceForm>(WorkspaceForm(
      name: InputForm(initWorkspace?.name, ''),
      path: InputForm(initWorkspace?.path, ''),
    ));

    return Container();
  }
}
