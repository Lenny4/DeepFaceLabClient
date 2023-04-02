import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/service/pythonService.dart';
import 'package:deepfacelab_client/viewModel/devices_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';

class DevicesWidget extends HookWidget {
  DevicesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    init() async {
      PythonService().updateDevices();
    }

    useEffect(() {
      init();
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MarkdownBody(selectable: true, data: "# Your GPUs"),
        StoreConnector<AppState, DevicesViewModel>(
            builder: (BuildContext context, DevicesViewModel vm) {
              return vm.devices == null
                  ? const CircularProgressIndicator()
                  : vm.devices != null && vm.devices!.isNotEmpty
                      ? Table(
                          border: TableBorder.all(color: Colors.white),
                          columnWidths: const <int, TableColumnWidth>{
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                            2: IntrinsicColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                TableCell(
                                  child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const SelectableText("Index")),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const SelectableText("Name")),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const SelectableText(
                                          "Total memory (Gb)")),
                                ),
                              ],
                            ),
                            ...vm.devices!
                                .map((device) => TableRow(
                                      children: <Widget>[
                                        TableCell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SelectableText(
                                                  device.index.toString())),
                                        ),
                                        TableCell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child:
                                                  SelectableText(device.name)),
                                        ),
                                        TableCell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SelectableText(device
                                                  .totalMemGb
                                                  .toString())),
                                        ),
                                      ],
                                    ))
                                .toList()
                          ],
                        )
                      : const MarkdownBody(
                          selectable: true,
                          data: "No GPU detected on your machine");
            },
            converter: (store) => DevicesViewModel.fromStore(store)),
      ],
    );
  }
}
