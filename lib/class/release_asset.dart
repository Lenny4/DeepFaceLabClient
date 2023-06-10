import 'package:json_annotation/json_annotation.dart';

part 'release_asset.g.dart';

@JsonSerializable()
class ReleaseAsset {
  @JsonKey(name: 'browser_download_url')
  String browserDownloadUrl;

  ReleaseAsset({
    required this.browserDownloadUrl,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) =>
      _$ReleaseAssetFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseAssetToJson(this);
}
