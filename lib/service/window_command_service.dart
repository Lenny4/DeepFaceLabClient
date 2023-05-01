import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:deepfacelab_client/class/question.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/class/valid_answer_regex.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/locale_storage_service.dart';

class _Questions {
  static Question enterFps = Question(
      text: 'Enter FPS',
      help: """Sets the framerate (frequency) of extraction.
Limit the amount of frames extracted from long clips and those with low variety.
If your clip has high variety or unique frames then you can extract all frames by entering ‘0’.""",
      validAnswerRegex: [
        ValidAnswerRegex(
            regex: '^(\\s*|\\d+)\$', errorMessage: 'You must enter a number')
      ],
      answer: '',
      defaultAnswer: '0');
  static Question outputImageFormat = Question(
      text: 'Output image format',
      help: """Select compressed JPEG or uncompressed PNG.
Choose png for the best image quality.""",
      validAnswerRegex: [
        ValidAnswerRegex(
            regex: '^\$|^png\$|^jpg\$',
            errorMessage: 'Choose one these values [png|jpg]')
      ],
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
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-2-extract-source-frame-images-from-video",
          key: 'extract_image_from_data_src',
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
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-3-extract-destination-frame-images-from-video",
          key: 'extract_image_from_data_dst',
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

  Future<LocaleStorageQuestion?> saveAndGetLocaleStorageQuestion(
      {required LocaleStorageQuestion localeStorageQuestion,
      required String workspacePath}) async {
    var storage = Storage.fromJson(await LocaleStorageService().readStorage());
    var workspace = storage.workspaces
        ?.firstWhereOrNull((workspace) => workspacePath == workspace.path);
    if (workspace == null) {
      return null;
    }
    workspace.localeStorageQuestions ??= [];
    int? localeStorageQuestionIndex = workspace.localeStorageQuestions
        ?.indexWhere((l) => l.key == localeStorageQuestion.key);
    if (localeStorageQuestionIndex == null ||
        localeStorageQuestionIndex == -1) {
      workspace.localeStorageQuestions!.add(localeStorageQuestion);
    } else {
      workspace.localeStorageQuestions![localeStorageQuestionIndex] =
          localeStorageQuestion;
    }
    store.dispatch({'storage': storage});
    return localeStorageQuestion;
  }
}
