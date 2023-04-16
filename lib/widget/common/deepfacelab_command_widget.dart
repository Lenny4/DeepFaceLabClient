import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/runningDeepfacelabCommand.dart';
import 'package:deepfacelab_client/class/startProcess.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/widget/common/start_process_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class _Command {
  String key;
  String title;
  String? workspacePath;
  String command;
  bool loading;
  String? Function(String) getAnswer;

  _Command(
      {required this.key,
      required this.title,
      required this.workspacePath,
      required this.command,
      required this.loading,
      required this.getAnswer});
}

class DeepfacelabCommandWidget extends HookWidget {
  final Workspace? workspace;

  const DeepfacelabCommandWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final runningDeepfacelabCommands =
        useSelector<AppState, List<RunningDeepfacelabCommand>>(
            (state) => state.runningDeepfacelabCommands);
    final dispatch = useDispatch<AppState>();
    final deepFaceLabFolder = useSelector<AppState, String?>(
        (state) => state.storage?.deepFaceLabFolder);

    List<_Command> getCommands() {
      if (workspace == null) {
        return [];
      }
      String keyExtractImageFromDataSrc = '2_extract_image_from_data_src';
      String keyExtractImageFromDataDst = '3_extract_image_from_data_dst';
      return [
        _Command(
            key: keyExtractImageFromDataSrc,
            workspacePath: workspace?.path,
            title: 'Extract image from data src',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_src.*" \\
--output-dir "${workspace?.path}/data_src"
            """,
            loading: runningDeepfacelabCommands?.firstWhereOrNull((element) =>
                    element.key == keyExtractImageFromDataSrc &&
                    element.workspacePath == workspace?.path) !=
                null,
            getAnswer: (String output) {
              if (output.contains('Enter FPS')) {
                return '0';
              }
              return null;
            }),
        _Command(
            key: keyExtractImageFromDataDst,
            workspacePath: workspace?.path,
            title: 'Extract image from data dst',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_dst.*" \\
--output-dir "${workspace?.path}/data_dst"
            """,
            loading: runningDeepfacelabCommands?.firstWhereOrNull((element) =>
                    element.key == keyExtractImageFromDataDst &&
                    element.workspacePath == workspace?.path) !=
                null,
            getAnswer: (String output) {
              if (output.contains('Enter FPS')) {
                return '0';
              }
              return null;
            }),
      ];
    }

    var commands = useState<List<_Command>>(getCommands());

    onRunningDeepfacelabCommandsUpdate() {
      var newCommands = commands.value.toList();
      for (var i = 0; i < newCommands.length; i++) {
        newCommands[i].loading = runningDeepfacelabCommands?.firstWhereOrNull(
                (element) =>
                    element.key == newCommands[i].key &&
                    element.workspacePath == newCommands[i].workspacePath) !=
            null;
      }
      commands.value = newCommands;
    }

    useEffect(() {
      commands.value = getCommands();
      return null;
    }, [workspace]);

    useEffect(() {
      onRunningDeepfacelabCommandsUpdate();
      return null;
    }, [runningDeepfacelabCommands]);

    return ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      initiallyExpanded: true,
      title: const Text('Commands'),
      tilePadding: const EdgeInsets.all(0.0),
      children: commands.value
          .map((command) => ListTile(
                onTap: command.loading
                    ? null
                    : () {
                        var newRunningDeepfacelabCommands = [
                          ...?runningDeepfacelabCommands
                        ];
                        if (newRunningDeepfacelabCommands.firstWhereOrNull(
                                (element) =>
                                    element.key == command.key &&
                                    workspace?.path == element.workspacePath) !=
                            null) {
                          return;
                        }
                        newRunningDeepfacelabCommands
                            .add(RunningDeepfacelabCommand(
                                key: command.key,
                                workspacePath: workspace?.path,
                                condaProcess: StartProcessWidget(
                                  autoStart: true,
                                  height: 200,
                                  closeIcon: true,
                                  startProcessesConda: [
                                    StartProcessConda(
                                        command: command.command,
                                        getAnswer: command.getAnswer)
                                  ],
                                  callback: () {
                                    // todo
                                    print("callback");
                                  },
                                )));
                        dispatch({
                          'runningDeepfacelabCommands':
                              newRunningDeepfacelabCommands
                        });
                      },
                title: Text(command.title),
                trailing: command.loading
                    ? ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red)),
                        onPressed: () {
                          print('stop');
                        },
                        child: const Text("Stop"),
                      )
                    : null,
              ))
          .toList(),
    );
  }
}
