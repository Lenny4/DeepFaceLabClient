// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valid_answer_regex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidAnswerRegex _$ValidAnswerRegexFromJson(Map<String, dynamic> json) =>
    ValidAnswerRegex(
      regex: json['regex'] as String?,
      min: json['min'] as int?,
      max: json['max'] as int?,
      errorMessage: json['errorMessage'] as String,
    );

Map<String, dynamic> _$ValidAnswerRegexToJson(ValidAnswerRegex instance) =>
    <String, dynamic>{
      'regex': instance.regex,
      'min': instance.min,
      'max': instance.max,
      'errorMessage': instance.errorMessage,
    };
