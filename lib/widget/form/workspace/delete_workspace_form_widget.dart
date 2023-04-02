import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/workspaceService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DeleteWorkspaceFormWidget extends HookWidget {
  final Workspace? workspace;

  const DeleteWorkspaceFormWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loading = useState<bool>(false);

    delete() async {
      loading.value = true;
      var thisWorkspace = workspace;
      if (thisWorkspace != null) {
        WorkspaceService().deleteWorkspace(workspace: thisWorkspace);
      }
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
                content: SelectableText(
                    'Do you really want to delete the workspace `${workspace?.name}` ? All the videos, images and models of the workspace will be deleted.'),
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
