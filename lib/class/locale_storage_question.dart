import 'package:deepfacelab_client/class/locale_storage_question_child.dart';
import 'package:json_annotation/json_annotation.dart';

part 'locale_storage_question.g.dart';

@JsonSerializable()
class LocaleStorageQuestion {
  String key;
  List<LocaleStorageQuestionChild> questions;

  LocaleStorageQuestion({
    required this.key,
    required this.questions,
  });

  factory LocaleStorageQuestion.fromJson(Map<String, dynamic> json) =>
      _$LocaleStorageQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$LocaleStorageQuestionToJson(this);
}
