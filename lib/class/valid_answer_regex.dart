import 'package:json_annotation/json_annotation.dart';

part 'valid_answer_regex.g.dart';

@JsonSerializable()
class ValidAnswerRegex {
  String? regex;
  double? min;
  double? max;
  String errorMessage;

  ValidAnswerRegex({
    this.regex,
    this.min,
    this.max,
    required this.errorMessage,
  });

  factory ValidAnswerRegex.fromJson(Map<String, dynamic> json) =>
      _$ValidAnswerRegexFromJson(json);

  Map<String, dynamic> toJson() => _$ValidAnswerRegexToJson(this);
}
