import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/widget/common/devices_widget.dart';
import 'package:deepfacelab_client/widget/common/file_manager_widget.dart';
import 'package:deepfacelab_client/widget/form/workspace/workspace_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../widget/form/workspace/delete_workspace_form_widget.dart';

class UpdateChildController {
  late void Function() updateFromParent;
}

class WorkspaceScreen extends HookWidget {
  final Workspace? initWorkspace;

  const WorkspaceScreen({Key? key, this.initWorkspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/a/53706941/6824121
    var mainController =
        useState<UpdateChildController>(UpdateChildController());
    var fileMissingController =
        useState<UpdateChildController>(UpdateChildController());

    updateFileMissingController() {
      fileMissingController.value.updateFromParent();
    }

    updateMainController() {
      mainController.value.updateFromParent();
    }

    return Scaffold(
      appBar: AppBar(
        title: SelectableText(
            "${initWorkspace == null ? "Create a workspace" : initWorkspace?.name}"),
      ),
      body: Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WorkspaceFormWidget(initWorkspace: initWorkspace),
                    if (initWorkspace != null) ...[
                      const Divider(),
                      FileManagerWidget(
                        rootPath: initWorkspace!.path,
                        controller: mainController.value,
                        updateFileMissing: updateFileMissingController,
                      ),
                    ]
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: const VerticalDivider(
                      thickness: 1, width: 1, color: Colors.white)),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DevicesWidget(),
                    if (initWorkspace != null) ...[
                      const FileManagerShortcutWidget(),
                      FileManagerMissingFolderWidget(
                        workspace: initWorkspace,
                        controller: fileMissingController.value,
                        updateMain: updateMainController,
                      ),
                    ],
                    DeleteWorkspaceFormWidget(workspace: initWorkspace)
                  ],
                )),
              ),
            ],
          )),
    );
  }
}
