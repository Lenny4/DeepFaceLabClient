import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/form/inputForm.dart';
import 'package:deepfacelab_client/class/form/workspaceForm.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/pythonService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';

class WorkspaceFormWidget extends HookWidget {
  final Workspace? initWorkspace;

  const WorkspaceFormWidget({Key? key, this.initWorkspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    var workspaceForm = useState<WorkspaceForm>(WorkspaceForm(
      name: InputForm(initWorkspace?.name, ''),
      path: InputForm(initWorkspace?.path, ''),
    ));

    checkIfPathIsOk() async {}

    init() async {
      checkIfPathIsOk();
      var devices = await PythonService().getDevices(store);
      String t = "";
    }

    useEffect(() {
      checkIfPathIsOk();
    }, [workspaceForm.value.path.value]);

    useEffect(() {
      init();
    }, []);

    return Container();
  }
}
