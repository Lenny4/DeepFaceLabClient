import 'package:json_annotation/json_annotation.dart';

part 'folder_property.g.dart';

@JsonSerializable()
class FolderProperty {
  int? size;
  String path;
  int? nbChildren;
  List<FolderProperty> folderProperties;

  FolderProperty(
      {this.size,
      required this.path,
      this.nbChildren,
      required this.folderProperties});

  factory FolderProperty.fromJson(Map<String, dynamic> json) =>
      _$FolderPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$FolderPropertyToJson(this);
}
