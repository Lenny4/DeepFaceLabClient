// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReleaseAsset _$ReleaseAssetFromJson(Map<String, dynamic> json) => ReleaseAsset(
      browserDownloadUrl: json['browser_download_url'] as String,
      name: json['name'] as String,
      downloadCount: json['download_count'] as int,
    );

Map<String, dynamic> _$ReleaseAssetToJson(ReleaseAsset instance) =>
    <String, dynamic>{
      'browser_download_url': instance.browserDownloadUrl,
      'name': instance.name,
      'download_count': instance.downloadCount,
    };
