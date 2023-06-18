// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) => Workspace(
      name: json['name'] as String,
      path: json['path'] as String,
      localeStorageQuestions: (json['localeStorageQuestions'] as List<dynamic>?)
          ?.map(
              (e) => LocaleStorageQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      folderProperty: json['folderProperty'] == null
          ? null
          : FolderProperty.fromJson(
              json['folderProperty'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'localeStorageQuestions': instance.localeStorageQuestions,
      'folderProperty': instance.folderProperty,
    };
