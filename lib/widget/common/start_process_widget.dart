import 'package:deepfacelab_client/class/start_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class StartProcessWidget extends HookWidget {
  final String label;
  final List<StartProcess> startProcesses;
  final Function? callback;

  const StartProcessWidget(
      {Key? key, required this.label, required this.startProcesses, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loading = useState<bool>(false);
    // https://docs.flutter.dev/cookbook/lists/long-lists
    // https://stackoverflow.com/questions/59927528/how-to-refresh-listview-builder-flutter

    onStart() async {
      loading.value = true;
      callback!(45);
      loading.value = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 1.0),
          child: ElevatedButton.icon(
            onPressed: loading.value ? null : onStart,
            icon: loading.value
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const SizedBox.shrink(),
            label: const Text('Install for me'),
          ),
        ),
        ExpansionTile(
          title: const Text('If you want to preview what will be run, click here'),
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: MarkdownBody(selectable: true, data: """
```shell
${startProcesses.join('\n\n')}
```
"""),
            )
          ],
        )
      ],
    );
  }
}
