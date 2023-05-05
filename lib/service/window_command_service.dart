import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/deepfacelab_command_group.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:deepfacelab_client/class/question.dart';
import 'package:deepfacelab_client/class/source.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/class/valid_answer_regex.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/locale_storage_service.dart';
import 'package:flutter/material.dart';

class _Questions {
  static Question enterFps = Question(
      text: 'Enter FPS',
      question: 'Enter FPS',
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
    question: 'Output image format',
    help: """Select compressed JPEG or uncompressed PNG.
Choose png for the best image quality.""",
    validAnswerRegex: [
      ValidAnswerRegex(
          regex: '^\$|^png\$|^jpg\$',
          errorMessage: 'Choose one these values [png|jpg]')
    ],
    answer: '',
    defaultAnswer: 'png',
    options: ['png', 'jpg'],
  );
  static Question chooseSortingMethod = Question(
    text: 'Choose sorting method',
    question: 'Choose sorting method',
    help: """- [0] blur: Sort by image blurriness based on contrast.
- [1] motion blur: Sort by motion blur.
- [2] face yaw direction: Sort by yaw (horizontal / left-to-right).
- [3] face pitch direction: Sort by pitch (vertical / up-to-down).
- [4] face rect size in source image: Sort by size of the face in the original video frame image (descending).
- [5] histogram similarity: Sort by histogram similarity (descending).
- [6] histogram dissimilarity: Sort by histogram similarity (ascending).
- [7] brightness: Sort by image brightness.
- [8] hue: Sort by image hue.
- [9] amount of black pixels: Sort by amount of black pixels in image (ascending).
- [10] original filename: Sort by order of original filename. Does not recover the original filename.
- [11] one face in image: Sort by the number of faces in the original video frame image (ascending).
- [12] absolute pixel difference: Sort by absolute difference.
- [13] best faces: Sort by multiple methods (w/ blur) and remove similar faces.
Select target number of face images to keep. Discarded faces moved to data_src/aligned_trash.
- [14] best faces faster: Sort by multiple methods (w/ face rect size) and remove similar faces.
Select target number of face images to keep. Discarded faces moved to data_src/aligned_trash.""",
    validAnswerRegex: [
      ValidAnswerRegex(
          regex: '^(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14)\$',
          errorMessage:
              'Choose one these values [0|1|2|3|4|5|6|7|8|9|10|11|12|13|14]')
    ],
    answer: '',
    defaultAnswer: '2',
    options: [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14'
    ],
  );
  static Question faceType = Question(
    text: 'Face type',
    question: 'Face type',
    help:
        """- [head]: Head. Covers entire head and hair to neck. Uses 3D landmarks.
- [wf]: Whole Face. Covers top of head to below chin.
- [f]: Full Face. Covers forehead to chin.""",
    validAnswerRegex: [
      ValidAnswerRegex(
          regex: '^(head|wf|f)\$',
          errorMessage: 'Choose one these values [head|wf|f]')
    ],
    answer: '',
    defaultAnswer: 'wf',
    options: [
      'head',
      'wf',
      'f',
    ],
  );
  static Question maxNumberOfFacesFromImage = Question(
    text: 'Max number of faces from image',
    question: 'Max number of faces from image',
    help: """Select the maximum number of faces to extract from each frame.
[Tooltip: If you extract a src faceset that has frames with a large number of faces, it is advisable to set max faces to 3 to speed up extraction. 0 – unlimited]
""",
    validAnswerRegex: [
      ValidAnswerRegex(min: 0, errorMessage: 'Enter a positive number or 0')
    ],
    answer: '',
    defaultAnswer: '0',
  );
  static Question imageSize = Question(
    text: 'Image size (256 – 2048)',
    question: 'Image size',
    help: """Select the size (resolution) of the extracted faceset image files.
[Tooltip: Output image size. The higher image size, the worse face-enhancer works. Use higher than 512 value only if the source image is sharp enough and the face does not need to be enhanced.]""",
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 256,
          max: 2048,
          errorMessage: 'Enter number between 256 and 2048')
    ],
    answer: '',
    defaultAnswer: '512',
  );
  static Question jpegQuality = Question(
    text: 'Jpeg quality',
    question: 'Jpeg quality',
    help:
        """Select the quality (compression) of the extracted faceset image files.
[Tooltip: Jpeg quality. The higher jpeg quality the larger the output file size.]""",
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 1, max: 100, errorMessage: 'Enter number between 1 and 100')
    ],
    answer: '',
    defaultAnswer: '90',
  );
  static Question writeDebugImagesToAlignedDebug = Question(
    text: 'Write debug images to aligned_debug',
    question: 'Write debug images to aligned_debug',
    help: """Choose whether or not to write debug images.
- [n]: No
- [y]: Yes""",
    answer: '',
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
}

class WindowCommandService {
  static String extractImageFromDataSrc = 'extract_image_from_data_src';
  static String extractImageFromDataDst = 'extract_image_from_data_dst';
  static String dataSrcExtractFacesS3FD = 'data_src_extract_faces_S3FD';
  static String dataDstExtractFacesS3FD = 'data_dst_extract_faces_S3FD';
  static String dataSrcSort = 'data_src_sort';
  static String dataDstSort = 'data_dst_sort';
  static String xsegDataSrcMaskEdit = 'xseg_data_src_mask_edit';
  static String xsegDataDstMaskEdit = 'xseg_data_dst_mask_edit';

  List<WindowCommand> getWindowCommands(
      {Workspace? workspace, String? deepFaceLabFolder}) {
    return [
      ...[
        Source(type: 'src', key: WindowCommandService.extractImageFromDataSrc),
        Source(type: 'dst', key: WindowCommandService.extractImageFromDataDst)
      ].map((source) => WindowCommand(
          windowTitle:
              '[${workspace?.name}] Extract image from data ${source.type.toUpperCase()}',
          title: 'Extract image from data ${source.type.toUpperCase()}',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-2-extract-source-frame-images-from-video",
          key: source.key,
          command: """
python $deepFaceLabFolder/main.py videoed extract-video \\
--input-file "${workspace?.path}/data_${source.type}.*" \\
--output-dir "${workspace?.path}/data_${source.type}"
            """,
          loading: false,
          questions: [
            _Questions.enterFps,
            _Questions.outputImageFormat,
          ],
          similarMessageRegex: [
            'frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed='
          ])),
      ...[
        Source(type: 'src', key: WindowCommandService.dataSrcExtractFacesS3FD),
        Source(type: 'dst', key: WindowCommandService.dataDstExtractFacesS3FD)
      ].map((source) => WindowCommand(
          windowTitle:
              '[${workspace?.name}] Extract face from data ${source.type.toUpperCase()} S3FD',
          title: 'Extract face from data ${source.type.toUpperCase()} S3FD',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-4-extract-source-faceset",
          key: source.key,
          command: """
python $deepFaceLabFolder/main.py extract \\
--input-dir "${workspace?.path}/data_${source.type}" \\
--output-dir "${workspace?.path}/data_${source.type}/aligned" \\
--detector s3fd
            """,
          loading: false,
          questions: [
            _Questions.faceType,
            _Questions.maxNumberOfFacesFromImage,
            _Questions.imageSize,
            _Questions.jpegQuality,
            _Questions.writeDebugImagesToAlignedDebug,
          ],
          similarMessageRegex: ['\\d+%\\|.*\\| \\d+\\/\\d+ \\[.*\\]'])),
      ...[
        Source(type: 'src', key: WindowCommandService.dataSrcSort),
        Source(type: 'dst', key: WindowCommandService.dataDstSort)
      ].map((source) => WindowCommand(
          windowTitle:
              '[${workspace?.name}] Data ${source.type.toUpperCase()} sort',
          title: 'Data ${source.type.toUpperCase()} sort',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-4-2-source-faceset-sortin-cleanup",
          key: source.key,
          command: """
python $deepFaceLabFolder/main.py sort \\
--input-dir "${workspace?.path}/data_${source.type}/aligned"
            """,
          loading: false,
          questions: [
            _Questions.chooseSortingMethod,
          ],
          similarMessageRegex: [])),
      ...[
        Source(type: 'src', key: WindowCommandService.xsegDataSrcMaskEdit),
        Source(type: 'dst', key: WindowCommandService.xsegDataDstMaskEdit)
      ].map((source) => WindowCommand(
            windowTitle:
                '[${workspace?.name}] XSeg data ${source.type.toUpperCase()} mask edit',
            title: 'XSeg data ${source.type.toUpperCase()} mask edit',
            documentationLink:
                "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
            key: source.key,
            command: """
python $deepFaceLabFolder/main.py xseg editor \\
--input-dir "${workspace?.path}/data_${source.type}/aligned"
            """,
            loading: false,
            questions: [],
            similarMessageRegex: [],
          )),
    ];
  }

  List<DeepfacelabCommandGroup> getGroupsDeepfacelabCommand(
      {Workspace? workspace, String? deepFaceLabFolder}) {
    var windowCommands = WindowCommandService().getWindowCommands(
        workspace: workspace, deepFaceLabFolder: deepFaceLabFolder);
    return [
      DeepfacelabCommandGroup(
          name: 'Extract images',
          icon: const Icon(Icons.video_camera_back),
          windowCommands: windowCommands
              .where((wc) => [
                    WindowCommandService.extractImageFromDataSrc,
                    WindowCommandService.extractImageFromDataDst,
                  ].contains(wc.key))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Extract faces',
          icon: const Icon(Icons.face),
          windowCommands: windowCommands
              .where((wc) => [
                    WindowCommandService.dataSrcExtractFacesS3FD,
                    WindowCommandService.dataDstExtractFacesS3FD,
                  ].contains(wc.key))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Sort images',
          icon: const Icon(Icons.sort),
          windowCommands: windowCommands
              .where((wc) => [
                    WindowCommandService.dataSrcSort,
                    WindowCommandService.dataDstSort,
                  ].contains(wc.key))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'XSeg',
          icon: const Icon(Icons.draw),
          windowCommands: windowCommands
              .where((wc) => [
                    WindowCommandService.xsegDataSrcMaskEdit,
                    WindowCommandService.xsegDataDstMaskEdit,
                  ].contains(wc.key))
              .toList()),
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
