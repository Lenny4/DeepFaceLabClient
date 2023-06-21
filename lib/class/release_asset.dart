import 'package:json_annotation/json_annotation.dart';

part 'release_asset.g.dart';

@JsonSerializable()
class ReleaseAsset {
  @JsonKey(name: 'browser_download_url')
  String browserDownloadUrl;
  String name;
  @JsonKey(name: 'download_count')
  int downloadCount;

  ReleaseAsset({
    required this.browserDownloadUrl,
    required this.name,
    required this.downloadCount,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) =>
      _$ReleaseAssetFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseAssetToJson(this);
}
