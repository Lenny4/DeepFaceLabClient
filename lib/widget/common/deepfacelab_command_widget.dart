import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/deepfacelab_command_group.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:deepfacelab_client/class/locale_storage_question_child.dart';
import 'package:deepfacelab_client/class/source.dart';
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

class _SingleDeepfacelabCommandWidget extends HookWidget {
  final Workspace? workspace;
  final WindowCommand windowCommand;
  final ValueNotifier<Future<LocaleStorageQuestion?> Function()?>
      saveAndGetLocaleStorageQuestion;
  final void Function({required String source}) onLaunch;

  const _SingleDeepfacelabCommandWidget(
      {Key? key,
      required this.workspace,
      required this.windowCommand,
      required this.saveAndGetLocaleStorageQuestion,
      required this.onLaunch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    thisShowDialog({String source = ""}) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: SelectableText(
              windowCommand.title.replaceAll(Source.replace, source)),
          content: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Documentation",
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(
                                Uri.parse(windowCommand.documentationLink),
                                mode: LaunchMode.platformDefault);
                          },
                      ),
                    ],
                  ),
                ),
                if (workspace != null)
                  DeepfacelabCommandFormWidget(
                      workspace: workspace!,
                      source: source,
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
              onPressed: () => onLaunch(source: source),
              icon: const SizedBox.shrink(),
              label: const Text("Start"),
            ),
          ],
        ),
      );
    }

    return ListTile(
      onTap: () => !windowCommand.loading && !windowCommand.multipleSource
          ? thisShowDialog()
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(windowCommand.title.replaceAll(Source.replace, "")),
          if (windowCommand.multipleSource)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: Source.types
                  .map((type) => ElevatedButton(
                        onPressed: !windowCommand.loading
                            ? () {
                                thisShowDialog(source: type);
                              }
                            : null,
                        child: Text(type),
                      ))
                  .toList(),
            ),
        ],
      ),
      trailing:
          windowCommand.loading ? const CircularProgressIndicator() : null,
    );
  }
}

class DeepfacelabCommandWidget extends HookWidget {
  final Workspace? workspace;

  const DeepfacelabCommandWidget({Key? key, required this.workspace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deepFaceLabFolder = useSelector<AppState, String?>(
        (state) => state.storage?.deepFaceLabFolder);
    var deepfacelabCommandGroups = useState<List<DeepfacelabCommandGroup>>(
        WindowCommandService().getGroupsDeepfacelabCommand(
            deepFaceLabFolder: deepFaceLabFolder, workspace: workspace));
    var saveAndGetLocaleStorageQuestion =
        useState<Future<LocaleStorageQuestion?> Function()?>(null);

    onGroupsDeepfacelabCommandUpdate() async {
      bool hasUpdate = false;
      for (var deepfacelabCommandGroup in deepfacelabCommandGroups.value) {
        for (var windowCommand in deepfacelabCommandGroup.windowCommands) {
          if (windowCommand.loading) {
            hasUpdate = true;
            windowCommand.command = windowCommand.command
                .replaceAll(Source.replace, windowCommand.source);
            var window = await DesktopMultiWindow.createWindow(
                jsonEncode(windowCommand.toJson()));
            window
              ..setFrame(const Offset(0, 0) & const Size(1280, 720))
              ..center()
              ..setTitle(windowCommand.windowTitle
                  .replaceAll(Source.replace, windowCommand.source))
              ..show();
            windowCommand.loading = false;
          }
        }
      }
      if (hasUpdate) {
        deepfacelabCommandGroups.value =
            deepfacelabCommandGroups.value.toList();
      }
    }

    onLaunch({required String source}) {
      if (saveAndGetLocaleStorageQuestion.value == null) {
        return;
      }
      saveAndGetLocaleStorageQuestion.value!()
          .then((LocaleStorageQuestion? localeStorageQuestion) {
        if (localeStorageQuestion == null) {
          return;
        }
        for (var deepfacelabCommandGroup in deepfacelabCommandGroups.value) {
          for (var windowCommand in deepfacelabCommandGroup.windowCommands) {
            if (localeStorageQuestion.key ==
                windowCommand.key.replaceAll(Source.replace, source)) {
              for (var y = 0; y < windowCommand.questions.length; y++) {
                var localeStorageQuestionChild = localeStorageQuestion.questions
                    .firstWhereOrNull((LocaleStorageQuestionChild question) =>
                        question.question ==
                        windowCommand.questions[y].question);
                if (localeStorageQuestionChild != null) {
                  windowCommand.questions[y].answer =
                      localeStorageQuestionChild.answer;
                }
              }
              windowCommand.source = source;
              windowCommand.loading = true;
              break;
            }
          }
        }
        deepfacelabCommandGroups.value =
            deepfacelabCommandGroups.value.toList();
        Navigator.pop(context);
      });
    }

    useEffect(() {
      deepfacelabCommandGroups.value = WindowCommandService()
          .getGroupsDeepfacelabCommand(
              deepFaceLabFolder: deepFaceLabFolder, workspace: workspace);
      return null;
    }, [workspace?.path]);

    useEffect(() {
      onGroupsDeepfacelabCommandUpdate();
      return null;
    }, [deepfacelabCommandGroups.value]);

    return workspace != null
        ? ExpansionTile(
            expandedAlignment: Alignment.topLeft,
            childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
            initiallyExpanded: true,
            title: const Text('Commands'),
            tilePadding: const EdgeInsets.all(0.0),
            children: deepfacelabCommandGroups.value
                .map((deepfacelabCommandGroup) => ExpansionTile(
                      expandedAlignment: Alignment.topLeft,
                      initiallyExpanded: false,
                      title: Row(
                        children: [
                          deepfacelabCommandGroup.icon,
                          Text(deepfacelabCommandGroup.name),
                        ],
                      ),
                      tilePadding: const EdgeInsets.all(0.0),
                      children: deepfacelabCommandGroup.windowCommands
                          .map((windowCommand) =>
                              _SingleDeepfacelabCommandWidget(
                                workspace: workspace,
                                windowCommand: windowCommand,
                                onLaunch: onLaunch,
                                saveAndGetLocaleStorageQuestion:
                                    saveAndGetLocaleStorageQuestion,
                              ))
                          .toList(),
                    ))
                .toList(),
          )
        : const SizedBox.shrink();
  }
}
