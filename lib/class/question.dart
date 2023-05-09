import 'package:deepfacelab_client/class/valid_answer_regex.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  String text;
  String question;
  String help;
  List<ValidAnswerRegex>? validAnswerRegex;
  String? answer;
  String defaultAnswer;
  List<String>? options;

  Question({
    required this.text,
    required this.question,
    required this.help,
    this.validAnswerRegex,
    this.answer = '',
    required this.defaultAnswer,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
