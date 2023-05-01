// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_storage_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocaleStorageQuestion _$LocaleStorageQuestionFromJson(
        Map<String, dynamic> json) =>
    LocaleStorageQuestion(
      key: json['key'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) =>
              LocaleStorageQuestionChild.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocaleStorageQuestionToJson(
        LocaleStorageQuestion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'questions': instance.questions,
    };
