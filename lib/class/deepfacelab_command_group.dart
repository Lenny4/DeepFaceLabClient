import 'package:deepfacelab_client/class/window_command.dart';
import 'package:flutter/widgets.dart';

class DeepfacelabCommandGroup {
  String name;
  List<WindowCommand> windowCommands;
  Widget icon;

  DeepfacelabCommandGroup({
    required this.name,
    required this.windowCommands,
    required this.icon,
  });
}
