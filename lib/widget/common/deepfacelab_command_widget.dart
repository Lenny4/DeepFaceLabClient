import 'dart:convert';

import 'package:deepfacelab_client/class/answer.dart';
import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/windowCommand.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class DeepfacelabCommandWidget extends HookWidget {
  final Workspace? workspace;

  const DeepfacelabCommandWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deepFaceLabFolder = useSelector<AppState, String?>(
        (state) => state.storage?.deepFaceLabFolder);

    List<WindowCommand> getCommands() {
      if (workspace == null) {
        return [];
      }
      return [
        WindowCommand(
            windowTitle: '[${workspace?.name}] Extract image from data src',
            title: 'Extract image from data src',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_src.*" \\
--output-dir "${workspace?.path}/data_src"
            """,
            loading: false,
            answers: [
              Answer(value: '0', outputs: ['Enter FPS']),
              Answer(value: 'png', outputs: ['Output image format']),
            ],
            regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
        WindowCommand(
            windowTitle: '[${workspace?.name}] Extract image from data dst',
            title: 'Extract image from data dst',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_dst.*" \\
--output-dir "${workspace?.path}/data_dst"
            """,
            loading: false,
            answers: [
              Answer(value: '0', outputs: ['Enter FPS']),
              Answer(value: 'png', outputs: ['Output image format']),
            ],
            regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
      ];
    }

    var commands = useState<List<WindowCommand>>(getCommands());

    onCommandUpdate() async {
      bool hasUpdate = false;
      for (var command in commands.value) {
        if (command.loading) {
          hasUpdate = true;
          var window = await DesktopMultiWindow.createWindow(
              jsonEncode(command.toJson()));
          window
            ..setFrame(const Offset(0, 0) & const Size(1280, 720))
            ..center()
            ..setTitle(command.windowTitle)
            ..show();
          command.loading = false;
        }
      }
      if (hasUpdate) {
        commands.value = commands.value.toList();
      }
    }

    useEffect(() {
      commands.value = getCommands();
      return null;
    }, [workspace]);

    useEffect(() {
      onCommandUpdate();
      return null;
    }, [commands.value]);

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
                        command.loading = true;
                        commands.value = commands.value.toList();
                      },
                title: Text(command.title),
                trailing:
                    command.loading ? const CircularProgressIndicator() : null,
              ))
          .toList(),
    );
  }
}
