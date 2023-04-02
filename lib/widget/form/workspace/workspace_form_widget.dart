import 'dart:io';

import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/workspaceService.dart';
import 'package:deepfacelab_client/widget/common/form/checkbox_form_fiel_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';

class WorkspaceFormWidget extends HookWidget {
  final Workspace? initWorkspace;

  const WorkspaceFormWidget({Key? key, this.initWorkspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    String? homeDirectory = (Platform.environment)['HOME'];
    final _formKey = GlobalKey<FormState>();

    getWorkspacePath() {
      return initWorkspace?.path ??
          store.state.storage?.workspaceDefaultPath ??
          homeDirectory ??
          "/";
    }

    getWorkspaceName() {
      return initWorkspace?.name ?? "";
    }

    getWorkspaceEdit() {
      return initWorkspace == null;
    }

    var workspaceCreateFolder = useState<bool>(true);
    var loading = useState<bool>(false);
    var edit = useState<bool>(getWorkspaceEdit());
    final workspaceNameController =
        TextEditingController(text: getWorkspaceName());
    final workspacePathController =
        TextEditingController(text: getWorkspacePath());

    selectFolder() async {
      var value = await FilesystemPicker.openDialog(
        title: 'Workspace path',
        context: context,
        rootDirectory: Directory("/"),
        directory: Directory(workspacePathController.text),
        fsType: FilesystemType.folder,
        pickText: 'Validate',
      );
      if (value == null) {
        return;
      }
      workspacePathController.text = value;
    }

    save() async {
      loading.value = true;
      _formKey.currentState?.save();
      await WorkspaceService().createUpdateWorkspace(
        oldWorkspace: initWorkspace,
        newWorkspace: Workspace(
            name: workspaceNameController.text,
            path: workspacePathController.text),
        createFolder: workspaceCreateFolder.value,
      );
      loading.value = false;
      edit.value = false;
    }

    onChangeInitWorkspace() {
      edit.value = getWorkspaceEdit();
      workspacePathController.text = getWorkspacePath();
      workspaceNameController.text = getWorkspaceName();
    }

    useEffect(() {
      onChangeInitWorkspace();
    }, [initWorkspace]);

    // https://docs.flutter.dev/cookbook/forms/validation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
            selectable: true,
            data:
                "# ${initWorkspace == null ? "Create a workspace" : edit.value == true ? "Edit workspace" : ""}"),
        if (edit.value == true) ...[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Workspace name', labelText: 'Workspace name'),
                  controller: workspaceNameController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for your workspace';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  readOnly: true,
                  controller: workspacePathController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Workspace path',
                    labelText: 'Workspace path',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.folder),
                      splashRadius: 20,
                      onPressed: selectFolder,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the path of your workspace';
                    }
                    return null;
                  },
                ),
                initWorkspace == null
                    ? CheckboxFormField(
                        title: const MarkdownBody(
                            selectable: true,
                            data: "Create a new folder for the workspace"),
                        initialValue: true,
                        onSaved: (bool? value) =>
                            workspaceCreateFolder.value = (value ?? true),
                      )
                    : const SelectableText(
                        "Tip: if you want to rename the folder according to the workspace name, select the parent folder of your workspace folder"),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (initWorkspace != null)
                        ElevatedButton.icon(
                          onPressed: !loading.value
                              ? () {
                                  edit.value = false;
                                }
                              : null,
                          icon: loading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const SizedBox.shrink(),
                          label: const Text("Cancel edit"),
                        ),
                      ElevatedButton.icon(
                        onPressed: !loading.value
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  save();
                                }
                              }
                            : null,
                        icon: loading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const SizedBox.shrink(),
                        label: Text(initWorkspace == null
                            ? 'Create workspace'
                            : "Edit workspace"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(children: [
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.edit),
                splashRadius: 20,
                tooltip: 'Edit',
                onPressed: () => edit.value = true,
              ),
            ),
            MarkdownBody(selectable: true, data: """
Name of the workspace: `${initWorkspace?.name}`

Path of the workspace: `${initWorkspace?.path}`
              """)
          ])
        ],
      ],
    );
  }
}
