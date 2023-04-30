import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/service/window_command_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// todo remove ?
class DeepfacelabCommandConfigWidget extends HookWidget {
  const DeepfacelabCommandConfigWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var windowCommands = useState<List<WindowCommand>>(
        WindowCommandService().getWindowCommands());

    return ExpansionTile(
      title: const Text("Commands configuration"),
      tilePadding: const EdgeInsets.all(0.0),
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: windowCommands.value
                .map((windowCommand) => ExpansionTile(
                      expandedAlignment: Alignment.topLeft,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(windowCommand.title),
                      children: windowCommand.questions
                          .map((question) => Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text("- ${question.text}"),
                              ))
                          .toList(),
                    ))
                .toList())
      ],
    );
  }
}
