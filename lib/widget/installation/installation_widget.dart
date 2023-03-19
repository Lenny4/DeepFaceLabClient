import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class InstallationWidget extends HookWidget {
  const InstallationWidget({Key? key}) : super(key: key);

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

    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Please install the following dependencies"),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                MarkdownBody(
                  data: """
```shell
apt install conda
```
""",
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  splashRadius: 20,
                  tooltip: 'Copy to clipboard',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: "your text"));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
