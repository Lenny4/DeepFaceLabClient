import 'package:deepfacelab_client/widget/common/devices_widget.dart';
import 'package:deepfacelab_client/widget/form/workspace_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WorkspaceScreen extends HookWidget {
  const WorkspaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText('Create a workspace'),
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DevicesWidget(),
                const Divider(height: 50),
                const WorkspaceFormWidget(),
              ],
            )),
      ),
    );
  }
}
