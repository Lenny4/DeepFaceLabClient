import 'package:deepfacelab_client/class/answer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'windowCommand.g.dart';

@JsonSerializable()
class WindowCommand {
  String windowTitle;
  String title;
  String command;
  bool loading;
  List<Answer> answers;

  WindowCommand({
    required this.windowTitle,
    required this.title,
    required this.command,
    required this.loading,
    required this.answers,
  });

  factory WindowCommand.fromJson(Map<String, dynamic> json) =>
      _$WindowCommandFromJson(json);

  Map<String, dynamic> toJson() => _$WindowCommandToJson(this);
}
