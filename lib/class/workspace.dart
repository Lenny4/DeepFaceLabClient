import 'package:deepfacelab_client/class/folder_property.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace {
  String name;
  String path;
  List<LocaleStorageQuestion>? localeStorageQuestions;
  FolderProperty? folderProperty;

  Workspace(
      {required this.name,
      required this.path,
      this.localeStorageQuestions,
      this.folderProperty});

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceToJson(this);
}
