// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      text: json['text'] as String,
      question: json['question'] as String,
      help: json['help'] as String,
      validAnswerRegex: (json['validAnswerRegex'] as List<dynamic>?)
          ?.map((e) => ValidAnswerRegex.fromJson(e as Map<String, dynamic>))
          .toList(),
      answer: json['answer'] as String? ?? '',
      defaultAnswer: json['defaultAnswer'] as String,
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'text': instance.text,
      'question': instance.question,
      'help': instance.help,
      'validAnswerRegex': instance.validAnswerRegex,
      'answer': instance.answer,
      'defaultAnswer': instance.defaultAnswer,
      'options': instance.options,
    };
