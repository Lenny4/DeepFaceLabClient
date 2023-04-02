// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Storage _$StorageFromJson(Map<String, dynamic> json) => Storage(
      deepFaceLabFolder: json['deepFaceLabFolder'] as String?,
      workspaceDefaultPath: json['workspaceDefaultPath'] as String?,
      workspaces: (json['workspaces'] as List<dynamic>?)
          ?.map((e) => Workspace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StorageToJson(Storage instance) => <String, dynamic>{
      'deepFaceLabFolder': instance.deepFaceLabFolder,
      'workspaceDefaultPath': instance.workspaceDefaultPath,
      'workspaces': instance.workspaces,
    };
