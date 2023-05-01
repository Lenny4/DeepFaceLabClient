import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:deepfacelab_client/class/locale_storage_question_child.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/window_command_service.dart';
import 'package:deepfacelab_client/widget/common/form/deepfacelab_command_form_widget.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepfacelabCommandWidget extends HookWidget {
  final Workspace? workspace;

  const DeepfacelabCommandWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deepFaceLabFolder = useSelector<AppState, String?>(
        (state) => state.storage?.deepFaceLabFolder);
    var windowCommands = useState<List<WindowCommand>>(WindowCommandService()
        .getWindowCommands(
            deepFaceLabFolder: deepFaceLabFolder, workspace: workspace));
    var saveAndGetLocaleStorageQuestion =
        useState<Future<LocaleStorageQuestion?> Function()?>(null);

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

    onLaunch() {
      if (saveAndGetLocaleStorageQuestion.value == null) {
        return;
      }
      saveAndGetLocaleStorageQuestion.value!()
          .then((LocaleStorageQuestion? localeStorageQuestion) {
        if (localeStorageQuestion == null) {
          return;
        }
        for (var i = 0; i < windowCommands.value.length; i++) {
          if (localeStorageQuestion.key == windowCommands.value[i].key) {
            for (var y = 0; y < windowCommands.value[i].questions.length; y++) {
              var localeStorageQuestionChild = localeStorageQuestion.questions
                  .firstWhereOrNull((LocaleStorageQuestionChild question) =>
                      question.text ==
                      windowCommands.value[i].questions[y].text);
              if (localeStorageQuestionChild != null) {
                windowCommands.value[i].questions[y].answer =
                    localeStorageQuestionChild.answer;
              }
            }
            windowCommands.value[i].loading = true;
            break;
          }
        }
        windowCommands.value = windowCommands.value.toList();
        Navigator.pop(context);
      });
    }

    useEffect(() {
      windowCommands.value = WindowCommandService().getWindowCommands(
          deepFaceLabFolder: deepFaceLabFolder, workspace: workspace);
      return null;
    }, [workspace?.path]);

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
                onTap: () => windowCommand.loading == false
                    ? showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: SelectableText(windowCommand.title),
                          content: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Documentation",
                                        style:
                                            const TextStyle(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(
                                                Uri.parse(windowCommand
                                                    .documentationLink),
                                                mode:
                                                    LaunchMode.platformDefault);
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                if (workspace != null)
                                  DeepfacelabCommandFormWidget(
                                      workspace: workspace!,
                                      saveAndGetLocaleStorageQuestion:
                                          saveAndGetLocaleStorageQuestion,
                                      windowCommand: windowCommand,
                                      onLaunch: onLaunch),
                              ],
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton.icon(
                              autofocus: true,
                              onPressed: onLaunch,
                              icon: const SizedBox.shrink(),
                              label: const Text("Start"),
                            ),
                          ],
                        ),
                      )
                    : null,
                title: Text(windowCommand.title),
                trailing: windowCommand.loading
                    ? const CircularProgressIndicator()
                    : null,
              ))
          .toList(),
    );
  }
}
