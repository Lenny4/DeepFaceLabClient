import 'package:json_annotation/json_annotation.dart';

part 'storage.g.dart';

@JsonSerializable()
class Storage {
  Storage({this.deepFaceLabFolder, this.workspaceDefaultPath});

  String? deepFaceLabFolder;
  String? workspaceDefaultPath;

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);
}
