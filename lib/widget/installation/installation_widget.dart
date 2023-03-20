import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallationWidget extends HookWidget {
  String gitInstallation = """sudo apt install git -y""";
  String ffmpegInstallation = """sudo apt install ffmpeg -y""";
  String condaInstallation =
      """curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
bash miniconda.sh -b && \
rm miniconda.sh""";
  String condaEnvVar = """sudo nano /etc/environment""";
  String homeDirectory = (Platform.environment)['HOME'] ?? "";

  InstallationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hasConda = useState<bool?>(null);
    var hasGit = useState<bool?>(null);
    var hasFfmpeg = useState<bool?>(null);

    void hasRequirements() async {
      hasConda.value = (await Process.run('which', ['conda'])).stdout != '';
      hasGit.value = (await Process.run('which', ['git'])).stdout != '';
      hasFfmpeg.value = (await Process.run('which', ['ffmpeg'])).stdout != '';
    }

    useEffect(() {
      hasRequirements();
    }, []);

    return (hasConda.value == false ||
            hasGit.value == false ||
            hasFfmpeg.value == false)
        ? Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Installation",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (hasGit.value == false)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Install git",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const MarkdownBody(
                          data:
                              """`git` was not found by running command `which git`.
                          
Please run this command to install git""",
                        ),
                        Row(
                          children: [
                            MarkdownBody(
                              data: """
```shell
$gitInstallation
```
""",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              splashRadius: 20,
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: gitInstallation));
                              },
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              bool newValue =
                                  (await Process.run('which', ['git']))
                                          .stdout !=
                                      '';
                              if (!newValue) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 2),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    content: const Text(
                                      '`git` was not found by running command `which git`',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    content: const Text(
                                      '`git` found',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                              hasGit.value = newValue;
                            },
                            child: const Text("Click here when it's done")),
                        const Divider(),
                      ],
                    ),
                  ),
                if (hasFfmpeg.value == false)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Install ffmpeg",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const MarkdownBody(
                          data:
                              """`ffmpeg` was not found by running command `which ffmpeg`.
                          
Please run this command to install ffmpeg""",
                        ),
                        Row(
                          children: [
                            MarkdownBody(
                              data: """
```shell
$ffmpegInstallation
```
""",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              splashRadius: 20,
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: ffmpegInstallation));
                              },
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              bool newValue =
                                  (await Process.run('which', ['ffmpeg']))
                                          .stdout !=
                                      '';
                              if (!newValue) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 2),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    content: const Text(
                                      '`ffmpeg` was not found by running command `which ffmpeg`',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    content: const Text(
                                      '`ffmpeg` found',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                              hasFfmpeg.value = newValue;
                            },
                            child: const Text("Click here when it's done")),
                        const Divider(),
                      ],
                    ),
                  ),
                if (hasConda.value == false)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Install Miniconda",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const MarkdownBody(
                          data:
                              """`conda` was not found by running command `which conda`.
                          
Please run this command to install which conda""",
                        ),
                        Row(
                          children: [
                            MarkdownBody(
                              data: """
```shell
$condaInstallation
```
""",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              splashRadius: 20,
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: condaInstallation));
                              },
                            )
                          ],
                        ),
                        const MarkdownBody(
                          data:
                              """Once conda has been installed you need to add it to you global env variables.

Edit your `/etc/environment` file and add `conda` to your `PATH`""",
                        ),
                        Row(
                          children: [
                            MarkdownBody(
                              data: """
```shell
$condaEnvVar
```
""",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              splashRadius: 20,
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: condaEnvVar));
                              },
                            )
                          ],
                        ),
                        const MarkdownBody(
                          data: """Your file should look like this
```                                                            
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
```
                          """,
                        ),
                        Row(
                          children: [
                            MarkdownBody(
                              data:
                                  """Add `$homeDirectory/miniconda3/bin` at the end like this""",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              splashRadius: 20,
                              tooltip: 'Copy to clipboard',
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(
                                    text: "$homeDirectory/miniconda3/bin"));
                              },
                            )
                          ],
                        ),
                        MarkdownBody(
                          data: """
```
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$homeDirectory/miniconda3/bin"
```
                          """,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    'Then restart your computer. If you still have this message after restarting your computer please ',
                              ),
                              TextSpan(
                                text: 'open an issue',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                        Uri.parse(
                                            'https://github.com/Lenny4/DeepFaceLabClient/issues'),
                                        mode: LaunchMode.platformDefault);
                                  },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  )
              ],
            ),
          )
        : Container();
  }
}
