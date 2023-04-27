import 'dart:convert';

import 'package:deepfacelab_client/class/answer.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/window_command.dart';
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

    List<WindowCommand> getWindowCommands() {
      if (workspace == null) {
        return [];
      }
      return [
        WindowCommand(
            windowTitle: '[${workspace?.name}] 2 Extract image from data src',
            title: '2 Extract image from data src',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_src.*" \\
--output-dir "${workspace?.path}/data_src"
            """,
            loading: false,
            answers: [
              Answer(value: '0', questions: ['Enter FPS']),
              Answer(value: 'png', questions: ['Output image format']),
            ],
            regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
        WindowCommand(
            windowTitle: '[${workspace?.name}] 3 Extract image from data dst',
            title: '3 Extract image from data dst',
            command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_dst.*" \\
--output-dir "${workspace?.path}/data_dst"
            """,
            loading: false,
            answers: [
              Answer(value: '0', questions: ['Enter FPS']),
              Answer(value: 'png', questions: ['Output image format']),
            ],
            regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
      ];
    }

    var windowCommands = useState<List<WindowCommand>>(getWindowCommands());

    onWindowCommandUpdate() async {
      bool hasUpdate = false;
      for (var windowCommand in windowCommands.value) {
        if (windowCommand.loading) {
          hasUpdate = true;
          var window = await DesktopMultiWindow.createWindow(
              jsonEncode(windowCommand.toJson()));
          window
            ..setFrame(const Offset(0, 0) & const Size(1280, 720))
            ..center()
            ..setTitle(windowCommand.windowTitle)
            ..show();
          windowCommand.loading = false;
        }
      }
      if (hasUpdate) {
        windowCommands.value = windowCommands.value.toList();
      }
    }

    useEffect(() {
      windowCommands.value = getWindowCommands();
      return null;
    }, [workspace]);

    useEffect(() {
      onWindowCommandUpdate();
      return null;
    }, [windowCommands.value]);

    return ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      initiallyExpanded: true,
      title: const Text('Commands'),
      tilePadding: const EdgeInsets.all(0.0),
      children: windowCommands.value
          .map((windowCommand) => ListTile(
                onTap: windowCommand.loading
                    ? null
                    : () {
                        windowCommand.loading = true;
                        windowCommands.value = windowCommands.value.toList();
                      },
                title: Text(windowCommand.title),
                trailing: windowCommand.loading
                    ? const CircularProgressIndicator()
                    : null,
              ))
          .toList(),
    );
  }
}
