import 'package:deepfacelab_client/class/valid_answer_regex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  String text;
  String help;
  List<ValidAnswerRegex> validAnswerRegex;
  String? answer;
  String? defaultAnswer;

  Question({
    required this.text,
    required this.help,
    required this.validAnswerRegex,
    this.answer,
    this.defaultAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
