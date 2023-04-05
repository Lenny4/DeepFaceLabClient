import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/workspaceService.dart';
import 'package:deepfacelab_client/widget/common/form/checkbox_form_fiel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DeleteWorkspaceFormWidget extends HookWidget {
  final Workspace? workspace;

  const DeleteWorkspaceFormWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loading = useState<bool>(false);
    var deleteFolder = useState<bool>(true);
    final _formKey = GlobalKey<FormState>();

    delete() async {
      loading.value = true;
      _formKey.currentState?.save();
      var thisWorkspace = workspace;
      if (thisWorkspace != null) {
        WorkspaceService().deleteWorkspace(
            workspace: thisWorkspace, deleteFolder: deleteFolder.value);
      }
      deleteFolder.value = true;
      loading.value = false;
    }

    return workspace != null
        ? ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red)),
            onPressed: () => showDialog<String>(
              barrierDismissible: !loading.value,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: SelectableText('Delete `${workspace?.name}`'),
                content: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SelectableText(
                            'Do you really want to delete the workspace `${workspace?.name}` ?'),
                        CheckboxFormField(
                          title: const MarkdownBody(
                              selectable: true,
                              data:
                                  "Delete the workspace folder on my computer"),
                          initialValue: deleteFolder.value,
                          onSaved: (bool? value) =>
                              deleteFolder.value = (value ?? true),
                        )
                      ],
                    ),
                  ),
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  ElevatedButton.icon(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)),
                    onPressed: !loading.value
                        ? () {
                            delete().then((value) => Navigator.pop(context));
                          }
                        : null,
                    icon: loading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const SizedBox.shrink(),
                    label: const Text("Yes"),
                  ),
                ],
              ),
            ),
            child: const Text("Delete workspace"),
          )
        : const SizedBox.shrink();
  }
}
