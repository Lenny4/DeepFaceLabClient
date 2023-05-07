import 'package:deepfacelab_client/class/question.dart';
import 'package:json_annotation/json_annotation.dart';

part 'window_command.g.dart';

@JsonSerializable()
class WindowCommand {
  String windowTitle;
  String title;
  String key;
  String documentationLink;
  String command;
  bool loading;
  String source;
  bool multipleSource;
  List<Question> questions;
  List<String> similarMessageRegex;

  WindowCommand({
    required this.windowTitle,
    required this.title,
    required this.key,
    required this.documentationLink,
    required this.command,
    required this.loading,
    this.source = "",
    required this.multipleSource, // if command can be launch on src and dst (display src and dst buttons)
    required this.questions,
    required this.similarMessageRegex,
  });

  factory WindowCommand.fromJson(Map<String, dynamic> json) =>
      _$WindowCommandFromJson(json);

  Map<String, dynamic> toJson() => _$WindowCommandToJson(this);
}
