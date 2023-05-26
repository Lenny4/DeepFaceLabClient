import 'dart:io';

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
import 'package:deepfacelab_client/service/python_service.dart';
import 'package:flutter/material.dart';
import 'package:slugify/slugify.dart';

class Questions {
  static String autoEnterQuestions =
      'Press enter.*to override.*|Choose one of saved models.*|Use interactive merger.*';
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
Select target number of face images to keep. Discarded faces moved to data_src${Platform.pathSeparator}aligned_trash.
- [14] best faces faster: Sort by multiple methods (w/ face rect size) and remove similar faces.
Select target number of face images to keep. Discarded faces moved to data_src${Platform.pathSeparator}aligned_trash.""",
    validAnswerRegex: [
      ValidAnswerRegex(
          regex: '^(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14)\$',
          errorMessage:
              'Choose one these values [0|1|2|3|4|5|6|7|8|9|10|11|12|13|14]')
    ],
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
    defaultAnswer: '90',
  );
  static Question writeDebugImagesToAlignedDebug = Question(
    text: 'Write debug images to aligned_debug',
    question: 'Write debug images to aligned_debug',
    help: """Choose whether or not to write debug images.
- [n]: No
- [y]: Yes""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question deleteOriginalFiles = Question(
    text: 'Delete original files',
    question: 'Delete original files',
    help: """Choose to deleted original files after packing.
- [n]: No
- [y]: Yes""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question batchSize = Question(
    text: 'Batch size',
    question: 'Batch_size',
    help: """Select the batch size for XSeg training""",
    defaultAnswer: '4',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 2, errorMessage: 'Enter a number greater or equal than 2')
    ],
  );
  static Question enablePretrainingModeXSeg = Question(
    text: 'Enable pretraining mode',
    question: 'Enable pretraining mode',
    help:
        """Choose to use the _internal/pretrain_faces faceset for XSeg training""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question chooseOneOrSeveralGpuIdxs = Question(
    text: 'Choose one or several GPU idxs (separated by comma)',
    question: 'Choose one or several GPU idxs',
    help: """Select one or more GPU indexes from the list to run extraction.
Recommend using identical devices when choosing multiple GPU indexes.""",
    defaultAnswer: 'CPU',
  );
  static Question whichGpuIndexesToChoose = Question(
    text: 'Which GPU indexes to choose (separated by comma)',
    question: 'Which GPU indexes to choose',
    help: """Select one or more GPU indexes from the list to run extraction.
Recommend using identical devices when choosing multiple GPU indexes.""",
    defaultAnswer: 'CPU',
  );
  static Question noSavedModelsFound = Question(
    text: 'Enter the name of the model',
    question: 'No saved models found',
    help: """Name your model.""",
    defaultAnswer: '',
  );
  static Question autobackupEveryNHour = Question(
      text: 'Autobackup every N hour',
      question: 'Autobackup every N hour',
      help: """Set the autobackup interval.
Autobackup model files with preview every N hour.
Latest backup located in model/<>_autobackups/01""",
      defaultAnswer: '0',
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
        '14',
        '15',
        '16',
        '17',
        '18',
        '19',
        '20',
        '21',
        '22',
        '23',
        '24',
      ]);
  static Question writePreviewHistory = Question(
      text: 'Write preview history',
      question: 'Write preview history',
      help: """Choose to write preview image history (every 30 iterations).
[Tooltip: Preview history will be writed to _history folder.]""",
      defaultAnswer: 'n',
      options: ['n', 'y']);
  static Question chooseImageForThePreviewHistory = Question(
      text: 'Choose image for the preview history',
      question: 'Choose image for the preview history',
      help: """(Conditional: Write preview history)
When training begins you will be prompted to choose the preview image for history generation.""",
      defaultAnswer: 'n',
      options: ['n', 'y']);
  static Question targetIteration = Question(
    text: 'Target iteration',
    question: 'Target iteration',
    help: """Set the target iteration to end and save training.
Set to 0 for uninterrupted training.""",
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, errorMessage: 'Enter a number greater or equal than 0')
    ],
    defaultAnswer: '0',
  );
  static Question flipSrcFacesRandomly = Question(
    text: 'Flip SRC faces randomly',
    question: 'Flip SRC faces randomly',
    help: """Random horizontal flip SRC faceset.
Covers more angles, but the face may look less naturally.""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question flipDstFacesRandomly = Question(
    text: 'Flip DST faces randomly',
    question: 'Flip DST faces randomly',
    help: """Random horizontal flip DST faceset.
Makes generalization of src->dst better, if src random flip is not enabled.""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question resolution = Question(
    text: 'Resolution (64 – 640)',
    question: 'Resolution',
    help: """More resolution requires more VRAM and time to train.
Value will be adjusted to multiple of 16 and 32 for -d archi.""",
    defaultAnswer: '128',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 64, max: 640, errorMessage: 'Enter a number between 64 and 640')
    ],
  );
  static Question aeArchitecture = Question(
    text: 'AE architecture',
    question: 'AE architecture',
    help: """‘df’ keeps more identity-preserved face.
‘liae’ can fix overly different face shapes.
‘-u’ increased likeness of the face.
‘-d’ doubling the resolution using the same computation cost.
‘-t’ Increases similarity to source face.
Examples: df, liae, df-d, df-ud, liae-ud, …]""",
    defaultAnswer: 'liae-udt',
    validAnswerRegex: [
      ValidAnswerRegex(
          regex: '^(liae|dt)-?(u|d|t)?(u|d|t)?(u|d|t)?\$',
          errorMessage: 'Architecture is invalid')
    ],
  );
  static Question autoEncoderDimensions = Question(
    text: 'AutoEncoder dimensions',
    question: 'AutoEncoder dimensions',
    help: """All face information will packed to AE dims.
If amount of AE dims are not enough, then for example closed eyes will not be recognized.
More dims are better, but require more VRAM.
You can fine-tune model size to fit your GPU.""",
    defaultAnswer: '256',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 32, max: 1024, errorMessage: 'Enter number between 32 and 1024')
    ],
  );
  static Question encoderDimensions = Question(
    text: 'Encoder dimensions',
    question: 'Encoder dimensions',
    help:
        """More dims help to recognize more facial features and achieve sharper result, but require more VRAM.
You can fine-tune model size to fit your GPU.""",
    defaultAnswer: '64',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 16, max: 256, errorMessage: 'Enter number between 16 and 256')
    ],
  );
  static Question decoderDimensions = Question(
    text: 'Decoder dimensions',
    question: 'Decoder dimensions',
    help:
        """: More dims help to recognize more facial features and achieve sharper result, but require more VRAM.
You can fine-tune model size to fit your GPU.""",
    defaultAnswer: '64',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 16, max: 256, errorMessage: 'Enter number between 16 and 256')
    ],
  );
  static Question decoderMaskDimensions = Question(
    text: 'Decoder mask dimensions',
    question: 'Decoder mask dimensions',
    help: """: Typical mask dimensions = decoder dimensions / 3.
If you manually cut out obstacles from the dst mask, you can increase this parameter to achieve better quality.""",
    defaultAnswer: '22',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 16, max: 256, errorMessage: 'Enter number between 16 and 256')
    ],
  );
  static Question maskedTraining = Question(
    text: 'Masked training',
    question: 'Masked training',
    help: """(Conditional: Face type wf or head)
This option is available only for ‘whole_face’ or ‘head’ type.
Masked training clips training area to full_face mask or XSeg mask, thus network will train the faces properly.""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question eyesAndMouthPriority = Question(
    text: 'Eyes and mouth priority',
    question: 'Eyes and mouth priority',
    help:
        """Helps to fix eye problems during training like “alien eyes” and wrong eyes direction.
Also makes the detail of the teeth higher.""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question uniformYawDistributionOfSamples = Question(
    text: 'Uniform yaw distribution of samples',
    question: 'Uniform yaw distribution of samples',
    help:
        """Helps to fix blurry side faces due to small amount of them in the faceset.""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question blurOutMask = Question(
    text: 'Blur out mask',
    question: 'Blur out mask',
    help: """Blurs nearby area outside of applied face mask of training samples.
The result is the background near the face is smoothed and less noticeable on swapped face.
The exact xseg mask in src and dst faceset is required.""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question placeModelsAndOptimizerOnGpu = Question(
    text: 'Place models and optimizer on GPU',
    question: 'Place models and optimizer on GPU',
    help:
        """When you train on one GPU, by default model and optimizer weights are placed on GPU to accelerate the process.
You can place they on CPU to free up extra VRAM, thus set bigger dimensions.""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question useAdaBeliefOptimizer = Question(
    text: 'Use AdaBelief optimizer',
    question: 'Use AdaBelief optimizer',
    help: """Use AdaBelief optimizer.
It requires more VRAM, but the accuracy and the generalization of the model is higher.""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question useLearningRateDropout = Question(
    text: 'Use learning rate dropout ( n / y / cpu )',
    question: 'Use learning rate dropout',
    help:
        """When the face is trained enough, you can enable this option to get extra sharpness and reduce subpixel shake for less amount of iterations.
Enabled it before disable random warp and before GAN.
n – disabled.
y – enabled
cpu – enabled on CPU. This allows not to use extra VRAM, sacrificing 20% time of iteration.""",
    defaultAnswer: 'n',
    options: ['y', 'n', 'cpu'],
  );
  static Question enableRandomWarpOfSamples = Question(
    text: 'Enable random warp of samples',
    question: 'Enable random warp of samples',
    help:
        """Random warp is required to generalize facial expressions of both faces.
When the face is trained enough, you can disable it to get extra sharpness and reduce subpixel shake for less amount of iterations.""",
    defaultAnswer: 'y',
    options: ['y', 'n'],
  );
  static Question randomHueSaturationLightIntensity = Question(
    text: 'Random hue/saturation/light intensity',
    question: 'Random hue/saturation/light intensity',
    help:
        """Random hue/saturation/light intensity applied to the src face set only at the input of the neural network.
Stabilizes color perturbations during face swapping.
Reduces the quality of the color transfer by selecting the closest one in the src faceset.
Thus the src faceset must be diverse enough.
Typical fine value is 0.05""",
    defaultAnswer: '0.0',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, max: 0.3, errorMessage: 'Enter number between 0.0 and 0.3')
    ],
  );
  static Question ganPower = Question(
    text: 'GAN power',
    question: 'GAN power',
    help: """Forces the neural network to learn small details of the face.
Enable it only when the face is trained enough with lr_dropout(on) and random_warp(off), and don’t disable.
The higher the value, the higher the chances of artifacts. Typical fine value is 0.1""",
    defaultAnswer: '0.0',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, max: 5, errorMessage: 'Enter number between 0.0 and 5.0')
    ],
  );
  static Question ganPatchSize = Question(
    text: 'GAN patch size',
    question: 'GAN patch size',
    help:
        """The higher patch size, the higher the quality, the more VRAM is required.
You can get sharper edges even at the lowest setting.
Typical fine value is resolution / 8.""",
    defaultAnswer: '16',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 3, max: 640, errorMessage: 'Enter number between 3 and 640')
    ],
  );
  static Question ganDimensions = Question(
    text: 'GAN dimensions',
    question: 'GAN dimensions',
    help: """The dimensions of the GAN network.
The higher dimensions, the more VRAM is required.
You can get sharper edges even at the lowest setting.
Typical fine value is 16.""",
    defaultAnswer: '16',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 4, max: 512, errorMessage: 'Enter number between 3 and 640')
    ],
  );
  static Question trueFacePower = Question(
    text: '‘True face’ power',
    question: '‘True face’ power',
    help: """Experimental option.
Discriminates result face to be more like src face.
Higher value – stronger discrimination.
Typical value is 0.01.""",
    defaultAnswer: '0.01',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, max: 1, errorMessage: 'Enter number between 0.0000 and 1.0')
    ],
  );
  static Question faceStylePower = Question(
    text: 'Face style power',
    question: 'Face style power',
    help:
        """Learn the color of the predicted face to be the same as dst inside mask.
If you want to use this option with ‘whole_face’ you have to use XSeg trained mask.
Warning: Enable it only after 10k iters, when predicted face is clear enough to start learn style.
Start from 0.001 value and check history changes.
Enabling this option increases the chance of model collapse.""",
    defaultAnswer: '0.0',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, max: 100, errorMessage: 'Enter number between 0.0 and 100.0')
    ],
  );
  static Question backgroundStylePower = Question(
    text: 'Background style power',
    question: 'Background style power',
    help:
        """Learn the area outside mask of the predicted face to be the same as dst.
If you want to use this option with ‘whole_face’ you have to use XSeg trained mask.
For whole_face you have to use XSeg trained mask.
This can make face more like dst. Enabling this option increases the chance of model collapse.
Typical value is 2.0""",
    defaultAnswer: '2.0',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 0, max: 100, errorMessage: 'Enter number between 0.0 and 100.0')
    ],
  );
  static Question colorTransferForSrcFaceset = Question(
    text:
        'Color transfer for src faceset ( none / rct / lct / mkl / idt / sot )',
    question: 'Color transfer for src faceset',
    help: """Change color distribution of src samples close to dst samples.
Try all modes to find the best.

- rct (reinhard color transfer)
- lct (linear color transfer): Matches the color distribution of the target image to that of the source image using a linear transform.
- mkl (Monge-Kantorovitch linear)
- idt (Iterative Distribution Transfer)
- sot (sliced optimal transfer)""",
    defaultAnswer: 'none',
    options: [
      'none',
      'rct',
      'lct',
      'mkl',
      'idt',
      'sot',
    ],
  );
  static Question enableGradientClipping = Question(
    text: 'Enable gradient clipping',
    question: 'Enable gradient clipping',
    help:
        """Gradient clipping reduces chance of model collapse, sacrificing speed of training.""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question enablePretrainingMode = Question(
    text: 'Enable pretraining mode',
    question: 'Enable pretraining mode',
    help: """Pretrain the model with large amount of various faces.
After that, model can be used to train the fakes more quickly.
Forces random_warp=N, random_flips=Y, gan_power=0.0, lr_dropout=N, styles=0.0, uniform_yaw=Y""",
    defaultAnswer: 'n',
    options: ['y', 'n'],
  );
  static Question bitrateOfOutputFile = Question(
    text: 'Bitrate of output file in MB/s',
    question: 'Bitrate of output file',
    help: """Select the video bitrate""",
    defaultAnswer: '16',
    validAnswerRegex: [
      ValidAnswerRegex(
          min: 1, errorMessage: 'Enter a number greater or equal than 1')
    ],
  );
}

class WindowCommandService {
  static String extractImageFromData = 'extract_image_from_data';
  static String dataExtractFacesS3FD = 'data_extract_faces_s3fd';
  static String dataExtractFacesManual = 'data_extract_faces_manual';
  static String dataSort = 'data_sort';
  static String facesetPack = 'faceset_pack';
  static String facesetUnpack = 'faceset_unpack';
  static String xsegDataMaskEdit = 'xseg_data_mask_edit';
  static String xsegDataMaskApply = 'xseg_data_mask_apply';
  static String xsegDataMaskFetch = 'xseg_data_mask_fetch';
  static String xsegDataMaskRemove = 'xseg_data_mask_remove';
  static String xsegDataTrainedMaskRemove = 'xseg_data_trained_mask_remove';
  static String xsegTrain = 'xseg_train';
  static String trainSaehd = 'train_SAEHD';
  static String trainQuick96 = 'train_Quick96';
  static String mergeSaehd = 'merge_SAEHD';
  static String mergeQuick96 = 'merge_Quick96';
  static String mergeMp4 = 'merge_mp4';
  static String mergeAvi = 'merge_avi';

  List<WindowCommand> getWindowCommands(
      {Workspace? workspace, String? deepFaceLabFolder}) {
    var pythonExec = PythonService().getPythonExec(deepFaceLabFolder);
    if(Platform.isWindows) {
      deepFaceLabFolder = "${deepFaceLabFolder ?? ""}\\DeepFaceLab";
    }
    return [
      // region extract images
      WindowCommand(
          workspace: workspace,
          windowTitle:
              '[${workspace?.name}] Extract image from data ${Source.replace}',
          title: 'Extract image from data ${Source.replace}',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-2-extract-source-frame-images-from-video",
          key: "${extractImageFromData}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py videoed extract-video \\
--input-file "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}.*" \\
--output-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}"
            """,
          loading: false,
          multipleSource: true,
          questions: [
            Questions.enterFps,
            Questions.outputImageFormat,
          ],
          similarMessageRegex: [
            'frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed='
          ]),
      // endregion
      // region extract faces
      WindowCommand(
          workspace: workspace,
          windowTitle:
              '[${workspace?.name}] Extract face from data ${Source.replace} S3FD',
          title: 'Extract face from data ${Source.replace} S3FD',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-4-extract-source-faceset",
          key: "${WindowCommandService.dataExtractFacesS3FD}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py extract \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}" \\
--output-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned" \\
--detector s3fd
            """,
          loading: false,
          multipleSource: true,
          questions: [
            Questions.whichGpuIndexesToChoose,
            Questions.faceType,
            Questions.maxNumberOfFacesFromImage,
            Questions.imageSize,
            Questions.jpegQuality,
            Questions.writeDebugImagesToAlignedDebug,
          ],
          similarMessageRegex: ['\\d+%\\|.*\\| \\d+\\/\\d+ \\[.*\\]']),
      WindowCommand(
          workspace: workspace,
          windowTitle:
              '[${workspace?.name}] Extract face from data ${Source.replace} manual',
          title: 'Extract face from data ${Source.replace} manual',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-4-extract-source-faceset",
          key:
              "${WindowCommandService.dataExtractFacesManual}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py extract \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}" \\
--output-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned" \\
--detector manual
            """,
          loading: false,
          multipleSource: true,
          questions: [
            Questions.whichGpuIndexesToChoose,
            Questions.faceType,
            Questions.maxNumberOfFacesFromImage,
            Questions.imageSize,
            Questions.jpegQuality,
            Questions.writeDebugImagesToAlignedDebug,
          ],
          similarMessageRegex: ['\\d+%\\|.*\\| \\d+\\/\\d+ \\[.*\\]']),
      // endregion
      // region XSeg
      WindowCommand(
        workspace: workspace,
        windowTitle:
            '[${workspace?.name}] XSeg data ${Source.replace} mask edit',
        title: 'XSeg data ${Source.replace} mask edit',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
        key: "${WindowCommandService.xsegDataMaskEdit}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py xseg editor \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned"
            """,
        loading: false,
        multipleSource: true,
        questions: [],
        similarMessageRegex: [],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle:
            '[${workspace?.name}] XSeg data ${Source.replace} mask apply',
        title: 'XSeg data ${Source.replace} mask apply',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
        key: "${WindowCommandService.xsegDataMaskApply}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py xseg apply \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model"
            """,
        loading: false,
        multipleSource: true,
        questions: [
          Questions.whichGpuIndexesToChoose,
        ],
        similarMessageRegex: [],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle:
            '[${workspace?.name}] XSeg data ${Source.replace} mask fetch',
        title: 'XSeg data ${Source.replace} mask fetch',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
        key: "${WindowCommandService.xsegDataMaskFetch}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py xseg fetch \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned"
            """,
        loading: false,
        multipleSource: true,
        questions: [],
        similarMessageRegex: [],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle:
            '[${workspace?.name}] XSeg data ${Source.replace} mask remove',
        title: 'XSeg data ${Source.replace} mask remove',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
        key: "${WindowCommandService.xsegDataMaskRemove}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py xseg remove_labels \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned"
            """,
        loading: false,
        multipleSource: true,
        questions: [],
        similarMessageRegex: [],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] XSeg train ${Source.replace}',
        title: 'XSeg train ${Source.replace}',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#xseg-model-training",
        key: "${WindowCommandService.xsegTrain}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py train \\
--training-data-src-dir "${workspace?.path}${Platform.pathSeparator}data_src${Platform.pathSeparator}aligned" \\
--training-data-dst-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model" \\
--model XSeg
            """,
        loading: false,
        multipleSource: true,
        questions: [
          Questions.chooseOneOrSeveralGpuIdxs,
          Questions.faceType,
          Questions.batchSize,
          Questions.enablePretrainingModeXSeg,
        ],
        similarMessageRegex: [
          'Loading samples.*\\d+.*',
          'Filtering:.*\\d+%.*',
          'Saving:.*\\d+%.*',
          '\\[\\d+:\\d+:\\d+\\]\\[\\#\\d+\\].*',
        ],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle:
            '[${workspace?.name}] XSeg data ${Source.replace} trained mask remove',
        title: 'XSeg data ${Source.replace} trained mask remove',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-3-xseg-mask-labeling-xseg-model-training",
        key:
            "${WindowCommandService.xsegDataTrainedMaskRemove}_${Source.replace}",
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py xseg remove \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned"
            """,
        loading: false,
        multipleSource: true,
        questions: [],
        similarMessageRegex: [],
      ),
      // endregion
      // region sort
      WindowCommand(
          workspace: workspace,
          windowTitle: '[${workspace?.name}] Data ${Source.replace} sort',
          title: 'Data ${Source.replace} sort',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-4-2-source-faceset-sortin-cleanup",
          key: "${WindowCommandService.dataSort}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py sort \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned"
            """,
          loading: false,
          multipleSource: true,
          questions: [
            Questions.chooseSortingMethod,
          ],
          similarMessageRegex: [
            'Loading:.*\\d+%.*',
            'Renaming:.*\\d+%.*',
          ]),
      // endregion
      // region pack and unpack
      WindowCommand(
          workspace: workspace,
          windowTitle: '[${workspace?.name}] Pack ${Source.replace}',
          title: 'Pack ${Source.replace}',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-2-destination-faceset-sorting-cleanup-re-extraction",
          key: "${WindowCommandService.facesetPack}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py util \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned" \\
--pack-faceset
            """,
          loading: false,
          multipleSource: true,
          questions: [
            Questions.deleteOriginalFiles,
          ],
          similarMessageRegex: [
            'Loading samples.*\\d+%.*',
            'Processing.*\\d+.*',
            'Packing.*\\d+.*',
            'Deleting files.*\\d+.*',
          ]),
      WindowCommand(
          workspace: workspace,
          windowTitle: '[${workspace?.name}] Unpack ${Source.replace}',
          title: 'Unpack ${Source.replace}',
          documentationLink:
              "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-5-2-destination-faceset-sorting-cleanup-re-extraction",
          key: "${WindowCommandService.facesetUnpack}_${Source.replace}",
          command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py util \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_${Source.replace}${Platform.pathSeparator}aligned" \\
--unpack-faceset
            """,
          loading: false,
          multipleSource: true,
          questions: [],
          similarMessageRegex: [
            'Unpacking.*\\d+%.*',
          ]),
      // endregion
      // region train
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Train SAEHD',
        title: 'Train SAEHD',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-6-deepfake-model-training",
        key: WindowCommandService.trainSaehd,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py train \\
--training-data-src-dir "${workspace?.path}${Platform.pathSeparator}data_src${Platform.pathSeparator}aligned" \\
--training-data-dst-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model" \\
--model SAEHD""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.chooseOneOrSeveralGpuIdxs,
          Questions.noSavedModelsFound,
          Questions.autobackupEveryNHour,
          Questions.writePreviewHistory,
          Questions.chooseImageForThePreviewHistory,
          Questions.targetIteration,
          Questions.flipSrcFacesRandomly,
          Questions.flipDstFacesRandomly,
          Questions.batchSize,
          Questions.resolution,
          Questions.faceType,
          Questions.aeArchitecture,
          Questions.autoEncoderDimensions,
          Questions.encoderDimensions,
          Questions.decoderDimensions,
          Questions.decoderMaskDimensions,
          Questions.maskedTraining,
          Questions.eyesAndMouthPriority,
          Questions.uniformYawDistributionOfSamples,
          Questions.blurOutMask,
          Questions.placeModelsAndOptimizerOnGpu,
          Questions.useAdaBeliefOptimizer,
          Questions.useLearningRateDropout,
          Questions.enableRandomWarpOfSamples,
          Questions.randomHueSaturationLightIntensity,
          Questions.ganPower,
          Questions.ganPatchSize,
          Questions.ganDimensions,
          Questions.trueFacePower,
          Questions.faceStylePower,
          Questions.backgroundStylePower,
          Questions.colorTransferForSrcFaceset,
          Questions.enableGradientClipping,
          Questions.enablePretrainingMode,
        ],
        similarMessageRegex: [
          'Loading samples.*\\d+.*',
          'Initializing models.*\\d+.*',
          'Saving:.*\\d+%.*',
          '\\[\\d+:\\d+:\\d+\\]\\[\\#\\d+\\].*',
        ],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Train Quick96',
        title: 'Train Quick96',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-6-deepfake-model-training",
        key: WindowCommandService.trainQuick96,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py train \\
--training-data-src-dir "${workspace?.path}${Platform.pathSeparator}data_src${Platform.pathSeparator}aligned" \\
--training-data-dst-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model" \\
--model Quick96""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.chooseOneOrSeveralGpuIdxs,
          Questions.noSavedModelsFound,
        ],
        similarMessageRegex: [
          'Loading samples.*\\d+.*',
          'Initializing models.*\\d+.*',
          'Saving:.*\\d+%.*',
          '\\[\\d+:\\d+:\\d+\\]\\[\\#\\d+\\].*',
        ],
      ),
      // endregion
      // region merge
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Merge SAEHD',
        title: 'Merge SAEHD',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-7-merge-deepfake-model-to-frame-images",
        key: WindowCommandService.mergeSaehd,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py merge \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst" \\
--output-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged" \\
--output-mask-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged_mask" \\
--aligned-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model" \\
--model SAEHD""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.chooseOneOrSeveralGpuIdxs,
        ],
        similarMessageRegex: [
          'Initializing models.*\\d+.*',
          'Collecting alignments.*\\d+.*',
          'Computing motion vectors.*\\d+.*',
          'Merging.*\\d+.*',
          'MergerConfig.*',
        ],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Merge Quick96',
        title: 'Merge Quick96',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-7-merge-deepfake-model-to-frame-images",
        key: WindowCommandService.mergeQuick96,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py merge \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst" \\
--output-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged" \\
--output-mask-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged_mask" \\
--aligned-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned" \\
--model-dir "${workspace?.path}${Platform.pathSeparator}model" \\
--model Quick96""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.chooseOneOrSeveralGpuIdxs,
        ],
        similarMessageRegex: [
          'Initializing models.*\\d+.*',
          'Collecting alignments.*\\d+.*',
          'Computing motion vectors.*\\d+.*',
          'Merging.*\\d+.*',
          'MergerConfig.*',
        ],
      ),
      // endregion
      // region to video
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Create mp4',
        title: 'Create mp4',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-8-merge-frame-images-to-video",
        key: WindowCommandService.mergeMp4,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py videoed video-from-sequence \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged" \\
--output-file "${workspace?.path}${Platform.pathSeparator}result.mp4" \\
--reference-file "${workspace?.path}${Platform.pathSeparator}data_dst.*" \\
--include-audio

$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py videoed video-from-sequence \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged_mask" \\
--output-file "${workspace?.path}${Platform.pathSeparator}result_mask.mp4" \\
--reference-file "${workspace?.path}${Platform.pathSeparator}data_dst.*" \\
--lossless""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.bitrateOfOutputFile,
        ],
        similarMessageRegex: [
          'frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=',
        ],
      ),
      WindowCommand(
        workspace: workspace,
        windowTitle: '[${workspace?.name}] Create avi',
        title: 'Create avi',
        documentationLink:
            "https://www.deepfakevfx.com/guides/deepfacelab-2-0-guide/#step-8-merge-frame-images-to-video",
        key: WindowCommandService.mergeAvi,
        command: """
$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py videoed video-from-sequence \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged" \\
--output-file "${workspace?.path}${Platform.pathSeparator}result.avi" \\
--reference-file "${workspace?.path}${Platform.pathSeparator}data_dst.*" \\
--include-audio

$pythonExec $deepFaceLabFolder${Platform.pathSeparator}main.py videoed video-from-sequence \\
--input-dir "${workspace?.path}${Platform.pathSeparator}data_dst${Platform.pathSeparator}merged_mask" \\
--output-file "${workspace?.path}${Platform.pathSeparator}result_mask.avi" \\
--reference-file "${workspace?.path}${Platform.pathSeparator}data_dst.*" \\
--lossless""",
        loading: false,
        multipleSource: false,
        questions: [
          Questions.bitrateOfOutputFile,
        ],
        similarMessageRegex: [
          'frame=.*fps=.*q=.*size=.*time=.*bitrate=.*speed=',
        ],
      ),
      // endregion
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
              .where((wc) =>
                  wc.key.contains(WindowCommandService.extractImageFromData))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Extract faces',
          icon: const Icon(Icons.face),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.dataExtractFacesS3FD) ||
                  wc.key.contains(WindowCommandService.dataExtractFacesManual))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'XSeg',
          icon: const Icon(Icons.draw),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.xsegDataMaskEdit) ||
                  wc.key.contains(WindowCommandService.xsegDataMaskApply) ||
                  wc.key.contains(WindowCommandService.xsegDataMaskRemove) ||
                  wc.key.contains(WindowCommandService.xsegDataMaskFetch) ||
                  wc.key.contains(
                      WindowCommandService.xsegDataTrainedMaskRemove) ||
                  wc.key.contains(WindowCommandService.xsegTrain))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Sort images',
          icon: const Icon(Icons.sort),
          windowCommands: windowCommands
              .where((wc) => wc.key.contains(WindowCommandService.dataSort))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Pack and unpack faceset',
          icon: const Icon(Icons.folder_zip),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.facesetPack) ||
                  wc.key.contains(WindowCommandService.facesetUnpack))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Train',
          icon: const Icon(Icons.model_training),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.trainSaehd) ||
                  wc.key.contains(WindowCommandService.trainQuick96))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'Merge',
          icon: const Icon(Icons.merge),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.mergeSaehd) ||
                  wc.key.contains(WindowCommandService.mergeQuick96))
              .toList()),
      DeepfacelabCommandGroup(
          name: 'To video',
          icon: const Icon(Icons.video_collection),
          windowCommands: windowCommands
              .where((wc) =>
                  wc.key.contains(WindowCommandService.mergeMp4) ||
                  wc.key.contains(WindowCommandService.mergeAvi))
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

  String getDefaultAnswer(
      {required Question question, required Workspace workspace}) {
    if (question.question == Questions.chooseOneOrSeveralGpuIdxs.question ||
        question.question == Questions.whichGpuIndexesToChoose.question) {
      var devices = store.state.devices;
      if (devices != null) {
        var indexes = [];
        for (int i = 0; i < devices.length; i++) {
          indexes.add(i);
        }
        if (indexes.isNotEmpty) {
          return indexes.join(",");
        }
      }
      return "CPU";
    }
    if (question.question == Questions.noSavedModelsFound.question) {
      return "${slugify(workspace.name)}_model";
    }
    return question.defaultAnswer;
  }
}
