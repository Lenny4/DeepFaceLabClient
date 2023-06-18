// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderProperty _$FolderPropertyFromJson(Map<String, dynamic> json) =>
    FolderProperty(
      size: json['size'] as int?,
      path: json['path'] as String,
      nbChildren: json['nbChildren'] as int?,
      folderProperties: (json['folderProperties'] as List<dynamic>)
          .map((e) => FolderProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FolderPropertyToJson(FolderProperty instance) =>
    <String, dynamic>{
      'size': instance.size,
      'path': instance.path,
      'nbChildren': instance.nbChildren,
      'folderProperties': instance.folderProperties,
    };
