import 'dart:convert';
import 'dart:io';

import 'package:deepfacelab_client/class/start_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class StartProcessWidget extends HookWidget {
  final String label;
  final List<StartProcess> startProcesses;
  final Function? callback;

  const StartProcessWidget(
      {Key? key,
      required this.label,
      required this.startProcesses,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loading = useState<bool>(false);
    var nbPkexec = useState<int>(0);

    // https://docs.flutter.dev/cookbook/lists/long-lists
    // https://stackoverflow.com/questions/59927528/how-to-refresh-listview-builder-flutter

    launchProcesses(int index) async {
      loading.value = true;
      var process = await Process.start(
          startProcesses[index].executable, startProcesses[index].arguments);
      process.stdout.transform(utf8.decoder).forEach((String output) {
        print(output);
      });
      process.stderr.transform(utf8.decoder).forEach((String output) {
        print(output);
      });
      process.exitCode.then((value) {
        if (index == startProcesses.length - 1) {
          callback!();
          loading.value = false;
        } else if (value == 0) {
          // success exit code
          launchProcesses(index + 1);
        }
      });
    }

    updateNbPkexec() {
      nbPkexec.value = startProcesses
          .where((startProcess) => startProcess.executable == 'pkexec')
          .length;
    }

    useEffect(() {
      updateNbPkexec();
    }, [startProcesses]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 1.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: !loading.value
                    ? () {
                        launchProcesses(0);
                      }
                    : null,
                icon: loading.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const SizedBox.shrink(),
                label: const Text('Install for me'),
              ),
              if (nbPkexec.value > 0)
                Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: Text(
                        'Your root password will be required ${nbPkexec.value} ${nbPkexec.value > 1 ? "times" : "time"}')),
            ],
          ),
        ),
        ExpansionTile(
          title:
              const Text('If you want to preview what will be run, click here'),
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: MarkdownBody(selectable: true, data: """
```shell
${startProcesses.map((startProcess) => "\$ $startProcess").join('\n\n')}
```
"""),
            )
          ],
        )
      ],
    );
  }
}
