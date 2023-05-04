// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowCommand _$WindowCommandFromJson(Map<String, dynamic> json) =>
    WindowCommand(
      windowTitle: json['windowTitle'] as String,
      title: json['title'] as String,
      key: json['key'] as String,
      documentationLink: json['documentationLink'] as String,
      command: json['command'] as String,
      loading: json['loading'] as bool,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      regex: (json['regex'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$WindowCommandToJson(WindowCommand instance) =>
    <String, dynamic>{
      'windowTitle': instance.windowTitle,
      'title': instance.title,
      'key': instance.key,
      'documentationLink': instance.documentationLink,
      'command': instance.command,
      'loading': instance.loading,
      'questions': instance.questions,
      'regex': instance.regex,
    };
