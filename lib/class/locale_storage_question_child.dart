import 'package:json_annotation/json_annotation.dart';

part 'locale_storage_question_child.g.dart';

@JsonSerializable()
class LocaleStorageQuestionChild {
  String question;
  String answer;

  LocaleStorageQuestionChild({
    required this.question,
    required this.answer,
  });

  factory LocaleStorageQuestionChild.fromJson(Map<String, dynamic> json) =>
      _$LocaleStorageQuestionChildFromJson(json);

  Map<String, dynamic> toJson() => _$LocaleStorageQuestionChildToJson(this);
}
