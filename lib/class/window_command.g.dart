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
      source: json['source'] as String? ?? "",
      multipleSource: json['multipleSource'] as bool,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      similarMessageRegex: (json['similarMessageRegex'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      workspace: json['workspace'] == null
          ? null
          : Workspace.fromJson(json['workspace'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WindowCommandToJson(WindowCommand instance) =>
    <String, dynamic>{
      'windowTitle': instance.windowTitle,
      'title': instance.title,
      'key': instance.key,
      'documentationLink': instance.documentationLink,
      'command': instance.command,
      'loading': instance.loading,
      'source': instance.source,
      'multipleSource': instance.multipleSource,
      'questions': instance.questions,
      'similarMessageRegex': instance.similarMessageRegex,
      'workspace': instance.workspace,
    };
