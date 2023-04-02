import 'dart:convert';
import 'dart:io';

import 'package:deepfacelab_client/class/startProcess.dart';
import 'package:deepfacelab_client/service/processService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class StartProcessWidget extends HookWidget {
  final String? label;
  final bool? autoStart;
  final bool? closeIcon;
  final double? height;
  final List<StartProcess>? startProcesses;
  final List<StartProcessConda>? startProcessesConda;
  final Function? callback;
  final ScrollController scrollController = ScrollController();

  StartProcessWidget(
      {Key? key,
      this.label,
      this.autoStart,
      this.closeIcon,
      this.height,
      this.startProcesses,
      this.startProcessesConda,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loading = useState<bool>(false);
    var nbPkexec = useState<int>(0);
    var ouputs = useState<List<String>>([]);

    launchProcesses(int index) async {
      if (index == 0) {
        ouputs.value = [];
      }
      loading.value = true;
      Process process;
      if (startProcesses != null) {
        process = await Process.start(startProcesses![index].executable,
            startProcesses![index].arguments);
      } else {
        String condaCommand =
            """${await ProcessService().getCondaPrefix(ouputs)} && \\
      ${startProcessesConda![index].command}""";
        process = await Process.start("bash", ['-c', condaCommand]);
      }
      if (startProcesses != null) {
        ouputs.value = [...ouputs.value, "\$ ${startProcesses![index]}"];
      } else {
        ouputs.value = [...ouputs.value, "\$ ${startProcessesConda![index]}"];
      }
      process.stdout.transform(utf8.decoder).forEach((String output) {
        ouputs.value = [...ouputs.value, output];
      });
      process.stderr.transform(utf8.decoder).forEach((String output) {
        ouputs.value = [...ouputs.value, output];
      });
      process.exitCode.then((value) {
        if ((startProcesses != null && index == startProcesses!.length - 1) ||
            (startProcessesConda != null &&
                index == startProcessesConda!.length - 1)) {
          if (callback != null) {
            callback!(value);
          }
          loading.value = false;
        } else if (value == 0) {
          // success exit code
          launchProcesses(index + 1);
        }
      });
    }

    updateNbPkexec() {
      if (startProcesses != null) {
        nbPkexec.value = startProcesses!
            .where((startProcess) => startProcess.executable == 'pkexec')
            .length;
      }
    }

    scrollDown() {
      if (scrollController.hasClients) {
        // https://stackoverflow.com/questions/75850193/make-scrollcontroller-scroll-bottom-if-already-at-bottom
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }

    useEffect(() {
      updateNbPkexec();
      if (autoStart == true) {
        launchProcesses(0);
      }
    }, [startProcesses]);

    useEffect(() {
      scrollDown();
    }, [ouputs.value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 1.0),
          child: Row(
            children: [
              if (label != null)
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
                  label: Text(label ?? ""),
                ),
              if (nbPkexec.value > 0)
                Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: Text(
                        'Your root password will be required ${nbPkexec.value} ${nbPkexec.value > 1 ? "times" : "time"}')),
            ],
          ),
        ),
        if (autoStart != true)
          ExpansionTile(
            title: const Text(
                'If you want to preview what will be run, click here'),
            tilePadding: const EdgeInsets.all(0.0),
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: MarkdownBody(selectable: true, data: """
```shell
${startProcesses!.map((startProcess) => "\$ $startProcess").join('\n\n')}
```
"""),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      splashRadius: 20,
                      tooltip: 'Copy to clipboard',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(
                            text: startProcesses!
                                .map((startProcess) => "$startProcess;")
                                .join('\n\n')));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        if (ouputs.value.isNotEmpty)
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 170,
                height: height ?? 500,
                color: Colors.white10,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: ouputs.value.length,
                  shrinkWrap: true,
                  prototypeItem: SelectableText(ouputs.value.first),
                  itemBuilder: (context, index) {
                    return SelectableText(ouputs.value[index]);
                  },
                ),
              ),
              if (closeIcon == true)
                IconButton(
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                  tooltip: 'Close',
                  onPressed: () {
                    ouputs.value = [];
                  },
                )
            ],
          )
      ],
    );
  }
}