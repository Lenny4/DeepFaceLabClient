import 'package:deepfacelab_client/class/answer.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';

class WindowCommandService {
  List<WindowCommand> getWindowCommands(
      {Workspace? workspace, String? deepFaceLabFolder}) {
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
            Answer(value: '0', question: 'Enter FPS'),
            Answer(value: 'png', question: 'Output image format'),
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
            Answer(value: '0', question: 'Enter FPS'),
            Answer(value: 'png', question: 'Output image format'),
          ],
          regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
    ];
  }
}
