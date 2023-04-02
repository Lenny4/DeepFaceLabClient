import 'package:deepfacelab_client/class/workspace.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storage.g.dart';

@JsonSerializable()
class Storage {
  Storage({this.deepFaceLabFolder, this.workspaceDefaultPath, this.workspaces});

  String? deepFaceLabFolder;
  String? workspaceDefaultPath;
  List<Workspace>? workspaces;

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);
}
