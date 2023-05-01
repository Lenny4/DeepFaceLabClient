import 'package:json_annotation/json_annotation.dart';

part 'valid_answer_regex.g.dart';

@JsonSerializable()
class ValidAnswerRegex {
  String regex;
  String errorMessage;

  ValidAnswerRegex({
    required this.regex,
    required this.errorMessage,
  });

  factory ValidAnswerRegex.fromJson(Map<String, dynamic> json) =>
      _$ValidAnswerRegexFromJson(json);

  Map<String, dynamic> toJson() => _$ValidAnswerRegexToJson(this);
}
