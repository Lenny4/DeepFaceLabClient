// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Release _$ReleaseFromJson(Map<String, dynamic> json) => Release(
      body: json['body'] as String,
      assets: (json['assets'] as List<dynamic>)
          .map((e) => ReleaseAsset.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagName: json['tag_name'] as String,
    );

Map<String, dynamic> _$ReleaseToJson(Release instance) => <String, dynamic>{
      'body': instance.body,
      'tag_name': instance.tagName,
      'assets': instance.assets,
    };
