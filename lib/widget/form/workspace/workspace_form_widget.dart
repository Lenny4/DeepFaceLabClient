import 'dart:io';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/platform_service.dart';
import 'package:deepfacelab_client/service/workspace_service.dart';
import 'package:deepfacelab_client/widget/common/divider_with_text_widget.dart';
import 'package:deepfacelab_client/widget/common/form/checkbox_form_fiel_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class WorkspaceFormWidget extends HookWidget {
  final Workspace? initWorkspace;

  const WorkspaceFormWidget({Key? key, this.initWorkspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String homeDirectory = PlatformService.getHomeDirectory();
    final workspaceDefaultPath = useSelector<AppState, String?>(
        (state) => state.storage?.workspaceDefaultPath);
    final createFormKey = GlobalKey<FormState>();
    final importFormKey = GlobalKey<FormState>();

    getWorkspacePath() {
      return initWorkspace?.path ?? workspaceDefaultPath ?? homeDirectory;
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
    final createWorkspaceNameController = useState<TextEditingController>(
        TextEditingController(text: getWorkspaceName()));
    final createWorkspacePathController = useState<TextEditingController>(
        TextEditingController(text: getWorkspacePath()));
    final importWorkspacePathController = useState<TextEditingController>(
        TextEditingController(text: getWorkspacePath()));

    selectFolder(ValueNotifier<TextEditingController> controller) async {
      var value = await FilesystemPicker.openDialog(
        title: 'Workspace path',
        context: context,
        rootDirectory: Directory(Platform.pathSeparator),
        directory: Directory(controller.value.text),
        fsType: FilesystemType.folder,
        pickText: 'Validate',
      );
      if (value == null) {
        return;
      }
      controller.value = TextEditingController(text: value);
    }

    createWorkspace() async {
      loading.value = true;
      createFormKey.currentState?.save();
      await WorkspaceService().createUpdateWorkspace(
        oldWorkspace: initWorkspace,
        newWorkspace: Workspace(
            name: createWorkspaceNameController.value.text,
            path: createWorkspacePathController.value.text),
        createFolder: workspaceCreateFolder.value,
      );
      loading.value = false;
      edit.value = false;
    }

    importWorkspace() async {
      loading.value = true;
      importFormKey.currentState?.save();
      await WorkspaceService()
          .importWorkspace(path: importWorkspacePathController.value.text);
      loading.value = false;
      edit.value = false;
    }

    onChangeInitWorkspace() {
      edit.value = getWorkspaceEdit();
      createWorkspaceNameController.value =
          TextEditingController(text: getWorkspaceName());
      createWorkspacePathController.value =
          TextEditingController(text: getWorkspacePath());
    }

    useEffect(() {
      onChangeInitWorkspace();
      return null;
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
            key: createFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Workspace name', labelText: 'Workspace name'),
                  controller: createWorkspaceNameController.value,
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
                  controller: createWorkspacePathController.value,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Workspace path',
                    labelText: 'Workspace path',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.folder),
                      splashRadius: 20,
                      onPressed: () =>
                          selectFolder(createWorkspacePathController),
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
                        initialValue: workspaceCreateFolder.value,
                        onChanged: (bool? value) =>
                            workspaceCreateFolder.value = (value ?? true),
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
                                if (createFormKey.currentState!.validate()) {
                                  createWorkspace();
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
          if (initWorkspace == null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: DividerWithTextWidget(text: "OR"),
            ),
            const MarkdownBody(selectable: true, data: "# Import a workspace"),
            Form(
              key: importFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    readOnly: true,
                    controller: importWorkspacePathController.value,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Workspace path',
                      labelText: 'Workspace path',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.folder),
                        splashRadius: 20,
                        onPressed: () =>
                            selectFolder(importWorkspacePathController),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select the path of your workspace';
                      }
                      return null;
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: !loading.value
                              ? () {
                                  if (importFormKey.currentState!.validate()) {
                                    importWorkspace();
                                  }
                                }
                              : null,
                          icon: loading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const SizedBox.shrink(),
                          label: const Text('Import workspace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ] else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
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
            ]),
          )
        ],
      ],
    );
  }
}
