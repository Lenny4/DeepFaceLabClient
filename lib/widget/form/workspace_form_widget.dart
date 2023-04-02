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

    var workspacePath = useState<String>(
        store.state.storage?.workspaceDefaultPath ?? homeDirectory ?? "/");
    var workspaceName = useState<String>("");
    var workspaceCreateFolder = useState<bool>(true);
    var loading = useState<bool>(false);
    var edit = useState<bool>(initWorkspace == null);

    selectFolder() async {
      var value = await FilesystemPicker.openDialog(
        title: 'Workspace path',
        context: context,
        rootDirectory: Directory("/"),
        directory: Directory(workspacePath.value),
        fsType: FilesystemType.folder,
        pickText: 'Validate',
      );
      if (value == null) {
        return;
      }
      workspacePath.value = value;
    }

    save() async {
      loading.value = true;
      _formKey.currentState?.save();
      await WorkspaceService().createUpdateWorkspace(
        oldWorkspace: initWorkspace,
        newWorkspace:
            Workspace(name: workspaceName.value, path: workspacePath.value),
        createFolder: workspaceCreateFolder.value,
      );
      workspaceName.value = "";
      loading.value = false;
    }

    onChangeInitWorkspace() {
      edit.value = initWorkspace == null;
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
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Workspace name', labelText: 'Workspace name'),
                  initialValue: workspaceName.value,
                  onSaved: (String? value) =>
                      workspaceName.value = (value ?? "workspace"),
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
                  onSaved: (String? value) => workspacePath.value = (value ??
                      store.state.storage?.workspaceDefaultPath ??
                      homeDirectory ??
                      "/"),
                  initialValue: workspacePath.value,
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
                CheckboxFormField(
                  title: MarkdownBody(
                      selectable: true,
                      data:
                          "Create a new folder in `${workspacePath.value}` for the workspace"),
                  initialValue: true,
                  onSaved: (bool? value) =>
                      workspaceCreateFolder.value = (value ?? true),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
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
                ),
              ],
            ),
          ),
        ] else
          ...[],
      ],
    );
  }
}
