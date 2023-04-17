// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'windowCommand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowCommand _$WindowCommandFromJson(Map<String, dynamic> json) =>
    WindowCommand(
      windowTitle: json['windowTitle'] as String,
      title: json['title'] as String,
      command: json['command'] as String,
      loading: json['loading'] as bool,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WindowCommandToJson(WindowCommand instance) =>
    <String, dynamic>{
      'windowTitle': instance.windowTitle,
      'title': instance.title,
      'command': instance.command,
      'loading': instance.loading,
      'answers': instance.answers,
    };
