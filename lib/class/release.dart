import 'package:deepfacelab_client/class/release_asset.dart';
import 'package:json_annotation/json_annotation.dart';

part 'release.g.dart';

@JsonSerializable()
class Release {
  String body;
  @JsonKey(name: 'tag_name')
  String tagName;
  List<ReleaseAsset> assets;

  Release({
    required this.body,
    required this.assets,
    required this.tagName,
  });

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseToJson(this);
}
