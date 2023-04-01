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
    final store = StoreProvider.of<AppState>(context);

    init() async {
      PythonService().updateDevices(store);
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
                      ? MarkdownBody(selectable: true, data: """
| Index        | Name         | Total memory (Gb) |
|--------------|--------------|-------------------|
${vm.devices!.map((device) => "|${device.index} | ${device.name} | ${device.totalMemGb} | \n").join()}
                      """)
                      : const MarkdownBody(
                          selectable: true,
                          data: "No GPU detected on your machine");
            },
            converter: (store) => DevicesViewModel.fromStore(store)),
      ],
    );
  }
}
