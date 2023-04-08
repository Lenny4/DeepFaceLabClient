import 'dart:io';

import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/startProcess.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/widget/common/open_issue_widget.dart';
import 'package:deepfacelab_client/widget/common/start_process_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallationWidget extends HookWidget {
  InstallationWidget({Key? key}) : super(key: key);
  String homeDirectory = (Platform.environment)['HOME'] ?? "/";

  @override
  Widget build(BuildContext context) {
    final hasRequirements =
        useSelector<AppState, bool>((state) => state.hasRequirements);
    final storage = useSelector<AppState, Storage?>((state) => state.storage);
    var loading = useState<bool>(false);
    var installationPath = useState<String?>(null);
    var startProcesses = useState<List<StartProcess>>([]);
    var startProcessesConda = useState<List<StartProcessConda>>([]);
    final dispatch = useDispatch<AppState>();

    afterFolderSelected(String path) {
      startProcessesConda.value = [
        StartProcessConda(command: """
pip install -r $path/requirements-cuda.txt
            """)
      ];
    }

    selectFolder(String title, String pickText, bool install) {
      FilesystemPicker.openDialog(
        title: title,
        context: context,
        rootDirectory: Directory(Platform.pathSeparator),
        directory: Directory(homeDirectory),
        fsType: FilesystemType.folder,
        pickText: pickText,
      ).then((value) {
        if (value == null) {
          return;
        }
        if (install) {
          loading.value = true;
          String thisInstallationPath = "$value/DeepFaceLab";
          installationPath.value = thisInstallationPath;
          startProcesses.value = [
            StartProcess(executable: 'bash', arguments: [
              '-c',
              """
rm -rf $thisInstallationPath && \
git clone --depth 1 https://github.com/iperov/DeepFaceLab.git $thisInstallationPath
            """
            ])
          ];
          startProcessesConda.value = [];
        } else {
          installationPath.value = value;
          afterFolderSelected(value);
        }
      });
    }

    onDownloadDone(int code) {
      afterFolderSelected(installationPath.value ?? "/");
    }

    onInstallationDone(int code) {
      if (code != 0) {
        loading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Row(
            children: [
              const SelectableText(
                'An error occurred while installing DeepFaceLab.',
                style: TextStyle(color: Colors.white),
              ),
              OpenIssue2Widget(),
            ],
          ),
          duration: const Duration(minutes: 1),
        ));
      } else {
        storage?.deepFaceLabFolder = installationPath.value;
        dispatch({'storage': storage});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          content: const SelectableText(
            'DeepFaceLabClient has been installed correctly. You can now create your first workspace!',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(minutes: 1),
        ));
      }
    }

    return hasRequirements == true
        ? Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarkdownBody(
                    selectable: true, data: """# Installation"""),
                storage?.deepFaceLabFolder == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "We did not find ",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                ),
                                TextSpan(
                                  text: ' DeepFaceLab',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                          Uri.parse(
                                              'https://github.com/iperov/DeepFaceLab'),
                                          mode: LaunchMode.platformDefault);
                                    },
                                ),
                                TextSpan(
                                  text: " on your computer.",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                const MarkdownBody(selectable: true, data: """
Please download it and specify where it is with the folder icon.
                                          """),
                                IconButton(
                                  icon: const Icon(Icons.folder),
                                  splashRadius: 20,
                                  onPressed: () {
                                    selectFolder(
                                        "Select you DeepFaceLab folder (it should contains a main.py file)",
                                        "Validate",
                                        false);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const MarkdownBody(
                                        selectable: true, data: """
Or click on install for me and let DeepFaceLabClient try to download and install DeepFaceLab
                                              """),
                                    ElevatedButton.icon(
                                      onPressed: !loading.value
                                          ? () {
                                              selectFolder(
                                                  "Select the folder where you want to install DeepFaceLab",
                                                  "Validate",
                                                  true);
                                            }
                                          : null,
                                      icon: loading.value
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const SizedBox.shrink(),
                                      label: const Text('Install for me'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : MarkdownBody(
                        selectable: true,
                        data:
                            """DeepFaceLab is installed here: `${storage?.deepFaceLabFolder}`"""),
                if (startProcesses.value.isNotEmpty)
                  StartProcessWidget(
                    autoStart: true,
                    height: 200,
                    closeIcon: true,
                    startProcesses: startProcesses.value,
                    callback: onDownloadDone,
                  ),
                if (startProcessesConda.value.isNotEmpty)
                  StartProcessWidget(
                    autoStart: true,
                    height: 200,
                    closeIcon: true,
                    startProcessesConda: startProcessesConda.value,
                    callback: onInstallationDone,
                  ),
              ],
            ))
        : const SizedBox.shrink();
  }
}
