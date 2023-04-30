import 'package:deepfacelab_client/class/question.dart';
import 'package:json_annotation/json_annotation.dart';

part 'window_command.g.dart';

@JsonSerializable()
class WindowCommand {
  String windowTitle;
  String title;
  String command;
  bool loading;
  List<Question> questions;
  List<String>? regex;

  WindowCommand({
    required this.windowTitle,
    required this.title,
    required this.command,
    required this.loading,
    required this.questions,
    this.regex,
  });

  factory WindowCommand.fromJson(Map<String, dynamic> json) =>
      _$WindowCommandFromJson(json);

  Map<String, dynamic> toJson() => _$WindowCommandToJson(this);
}
