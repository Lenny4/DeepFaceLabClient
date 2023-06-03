import 'dart:io';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/start_process.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/service/platform_service.dart';
import 'package:deepfacelab_client/widget/common/open_issue_widget.dart';
import 'package:deepfacelab_client/widget/common/start_process_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

class _VersionUrl {
  String label;
  String url;

  _VersionUrl({
    required this.label,
    required this.url,
  });
}

class InstallationWidget extends HookWidget {
  InstallationWidget({Key? key}) : super(key: key);
  final String homeDirectory = PlatformService.getHomeDirectory();

  @override
  Widget build(BuildContext context) {
    final hasRequirements =
        useSelector<AppState, bool>((state) => state.hasRequirements);
    final storage = useSelector<AppState, Storage?>((state) => state.storage);
    var loading = useState<bool>(false);
    var showInstallationMessage = useState<bool>(false);
    var installationPath = useState<String?>(null);
    var startProcesses = useState<List<StartProcess>>([]);
    var startProcessesConda = useState<List<StartProcessConda>>([]);
    final dispatch = useDispatch<AppState>();

    onInstallationDone(int code) {
      if (code != 0) {
        loading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Row(
            children: const [
              SelectableText(
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

    afterFolderSelected(String path) {
      if (Platform.isLinux) {
        startProcessesConda.value = [
          StartProcessConda(command: """
pip install -r $path/requirements-cuda.txt
            """)
        ];
      } else if (Platform.isWindows) {
        onInstallationDone(0);
      }
      showInstallationMessage.value = false;
    }

    selectFolder(String title, String pickText, bool install,
        [String url = ""]) {
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
          showInstallationMessage.value = true;
          if (Platform.isLinux) {
            String thisInstallationPath =
                "$value${Platform.pathSeparator}DeepFaceLab";
            installationPath.value = thisInstallationPath;
            startProcesses.value = [
              StartProcess(executable: 'bash', arguments: [
                '-c',
                """
rm -rf $thisInstallationPath &&
git clone --depth 1 https://github.com/iperov/DeepFaceLab.git $thisInstallationPath
            """
              ])
            ];
          } else if (Platform.isWindows) {
            String thisInstallationPath =
                "$value${Platform.pathSeparator}_internal";
            installationPath.value = thisInstallationPath;
            startProcesses.value = [
              StartProcess(executable: 'curl', arguments: [
                '--output',
                '$thisInstallationPath.zip',
                '--url',
                url,
              ], similarMessageRegex: [
                '\\d+.*\\d+.*\\d+.*\\d+.*\\d+.*\\d+.*\\d+:\\d+:\\d+:*\\d+.*\\d+.*\\d+.*\\d+.*\\d+.*'
              ]),
              StartProcess(executable: 'tar', arguments: [
                '-xf',
                '$thisInstallationPath.zip',
                '-C',
                value,
              ]),
            ];
          }
          startProcessesConda.value = [];
        } else {
          installationPath.value = value;
          afterFolderSelected(value);
        }
      });
    }

    selectInstallation() {
      if (Platform.isLinux) {
        selectFolder("Select the folder where you want to install DeepFaceLab",
            "Validate", true);
      } else if (Platform.isWindows) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const SelectableText('Select your version'),
            content: IntrinsicHeight(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VersionUrl(
                        label: "DeepFaceLab_DirectX12 (1.51Go)",
                        url:
                            "https://deepfacelab-internal.s3.amazonaws.com/_internal_directX12.zip"),
                    _VersionUrl(
                        label: "DeepFaceLab_NVIDIA_RTX3000 (5.16Go)",
                        url:
                            "https://deepfacelab-internal.s3.amazonaws.com/_internal_NVIDIA_RTX3000.zip"),
                    _VersionUrl(
                        label: "DeepFaceLab_NVIDIA_up_to_RTX2080Ti (2.89Go)",
                        url:
                            "https://deepfacelab-internal.s3.amazonaws.com/_internal_NVIDIA_up_to_RTX2080Ti.zip"),
                  ]
                      .map((versionUrl) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                selectFolder(
                                    "Select the folder where you want to install DeepFaceLab",
                                    "Validate",
                                    true,
                                    versionUrl.url);
                              },
                              icon: const SizedBox.shrink(),
                              label: Text(versionUrl.label),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
          ),
        );
      }
    }

    onDownloadDone(int code) async {
      if (code == 0) {
        if (Platform.isWindows) {
          var fileZip = File("${installationPath.value}.zip");
          if (fileZip.existsSync()) {
            fileZip.deleteSync();
          }
        }
        afterFolderSelected(installationPath.value ?? Platform.pathSeparator);
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
                                        Platform.isLinux
                                            ? "Select you DeepFaceLab folder (it should contains a main.py file)"
                                            : "Select you DeepFaceLab folder (it should be named _internal)",
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
                                              selectInstallation();
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
                if (showInstallationMessage.value)
                  const MarkdownBody(
                      selectable: true,
                      data:
                          """The installation may take up to 15min according to your computer"""),
                if (startProcesses.value.isNotEmpty)
                  StartProcessWidget(
                    workspace: null,
                    autoStart: true,
                    height: 200,
                    closeIcon: true,
                    usePrototypeItem: false,
                    startProcesses: startProcesses.value,
                    callback: onDownloadDone,
                  ),
                if (startProcessesConda.value.isNotEmpty)
                  StartProcessWidget(
                    workspace: null,
                    autoStart: true,
                    height: 200,
                    closeIcon: true,
                    usePrototypeItem: false,
                    startProcessesConda: startProcessesConda.value,
                    callback: onInstallationDone,
                  ),
              ],
            ))
        : const SizedBox.shrink();
  }
}
