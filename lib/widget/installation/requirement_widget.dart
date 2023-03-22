import 'dart:io';

import 'package:deepfacelab_client/widget/common/open_issue_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class RequirementWidget extends HookWidget {
  String homeDirectory = (Platform.environment)['HOME'] ?? "";

  RequirementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var requirements = useState<Map<String, bool>?>(null);
    var requirementOk = useState<bool?>(null);
    var loading = useState<bool>(false);
    var commands = useState<List<String>>([]);

    updateRequirements() async {
      requirements.value = {
        'hasBash': (await Process.run('which', ['bash'])).stdout == '',
        'hasGit': (await Process.run('which', ['git'])).stdout == '',
        'hasFfmpeg': (await Process.run('which', ['ffmpeg'])).stdout == '',
        'hasConda': (await Process.run('which', ['conda'])).stdout == '',
      };
      requirementOk.value = requirements.value?.entries
          .map<bool>((e) => e.value)
          .reduce((value, element) => value && element);
    }

    onUpdateRequirements() async {
      loading.value = true;
      await updateRequirements();
      loading.value = false;
    }

    useEffect(() {
      updateRequirements();
    }, []);

    return (requirements.value != null)
        ? Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  selectable: true,
                  data: """# Requirements

${requirements.value!['hasBash'] == true ? "✅ `bash`" : "❌ `bash` was not found by running command `which bash`, just run `sudo apt install bash -y` to install it"}

${requirements.value!['hasGit'] == true ? "✅ `git`" : "❌ `git` was not found by running command `which git`, just run `sudo apt install git -y` to install it"}

${requirements.value!['hasFfmpeg'] == true ? "✅ `ffmpeg`" : "❌ `ffmpeg` was not found by running command `which ffmpeg`, just run `sudo apt install ffmpeg -y` to install it"}
                  """,
                ),
                requirements.value!['hasConda'] == true
                    ? RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "✅ ",
                            ),
                            TextSpan(
                                text: "conda",
                                style: TextStyle(
                                  background: Paint()..color = Colors.white10,
                                )),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "❌ ",
                              ),
                              TextSpan(
                                  text: "conda",
                                  style: TextStyle(
                                    background: Paint()..color = Colors.white10,
                                  )),
                              const TextSpan(
                                text: " was not found by running command ",
                              ),
                              TextSpan(
                                  text: "which conda",
                                  style: TextStyle(
                                    background: Paint()..color = Colors.white10,
                                  )),
                              const TextSpan(
                                text: ", to install ",
                              ),
                              TextSpan(
                                  text: "conda",
                                  style: TextStyle(
                                    background: Paint()..color = Colors.white10,
                                  )),
                              TextSpan(
                                text: ' follow the tutorial',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                        Uri.parse(
                                            'https://docs.conda.io/projects/conda/en/latest/user-guide/install/'),
                                        mode: LaunchMode.platformDefault);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: MarkdownBody(
                    selectable: true,
                    data: """
${requirementOk.value == true ? """
Everything is installed !
""" : """
You need to install the missing packages.

- You can do it yourself and then click on `Verify my requirements`.
- Or you can click on `Install for me` and DeepFaceLabClient will try to install all missing packages for you.
"""}
                    """,
                  ),
                ),
                if (requirementOk.value == false)
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: ElevatedButton.icon(
                      onPressed: loading.value ? null : onUpdateRequirements,
                      icon: loading.value
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const SizedBox.shrink(),
                      label: const Text('Verify my requirements'),
                    ),
                  ),
                if (requirementOk.value == false)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: OpenIssueWidget()),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
