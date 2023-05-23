import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/device.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/python_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class DevicesWidget extends HookWidget {
  final Workspace? workspace;

  const DevicesWidget({Key? key, required this.workspace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devices =
        useSelector<AppState, List<Device>?>((state) => state.devices);

    initWidget() async {
      PythonService().updateDevices(workspace);
    }

    useEffect(() {
      initWidget();
      return null;
    }, []);

    return ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      title: Text(
          'Your GPUs ${(devices != null && devices.isNotEmpty ? "(${devices.length})" : "")}'),
      tilePadding: const EdgeInsets.all(0.0),
      children: <Widget>[
        devices == null
            ? const CircularProgressIndicator()
            : devices.isNotEmpty
                ? Table(
                    border: TableBorder.all(color: Colors.white),
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(),
                      1: IntrinsicColumnWidth(),
                      2: IntrinsicColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                                child:
                                    const SelectableText("Total memory (Gb)")),
                          ),
                        ],
                      ),
                      ...devices
                          .map((device) => TableRow(
                                children: <Widget>[
                                  TableCell(
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SelectableText(
                                            device.index.toString())),
                                  ),
                                  TableCell(
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SelectableText(device.name)),
                                  ),
                                  TableCell(
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SelectableText(
                                            device.totalMemGb.toStringAsFixed(2))),
                                  ),
                                ],
                              ))
                          .toList()
                    ],
                  )
                : const MarkdownBody(
                    selectable: true, data: "No GPU detected on your machine"),
      ],
    );
  }
}
