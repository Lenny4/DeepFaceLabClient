import 'package:deepfacelab_client/class/question.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';

class _Questions {
  static Question enterFps = Question(
      text: 'Enter FPS', validAnswerRegex: '', answer: '', defaultAnswer: '0');
  static Question outputImageFormat = Question(
      text: 'Output image format',
      validAnswerRegex: '',
      answer: '',
      defaultAnswer: 'png');
}

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
          questions: [
            _Questions.enterFps,
            _Questions.outputImageFormat,
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
          questions: [
            _Questions.enterFps,
            _Questions.outputImageFormat,
          ],
          regex: ['frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=']),
    ];
  }
}
