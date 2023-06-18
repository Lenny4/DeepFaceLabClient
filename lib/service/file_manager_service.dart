import 'dart:io';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/folder_property.dart';
import 'package:deepfacelab_client/service/workspace_service.dart';

import '../class/workspace.dart';

class FileManagerService {
  Future<FolderProperty> _updateFolderProperty(
      {required FolderProperty folderProperty,
      required List<FileSystemEntity> fileSystemEntities}) async {
    folderProperty.nbChildren = fileSystemEntities.length;
    var size = 0;
    List<String> foldersFound = [];
    for (var fileSystemEntity in fileSystemEntities) {
      if (fileSystemEntity is File) {
        size += await fileSystemEntity.length();
      }
      if (fileSystemEntity is Directory) {
        var thisFileSystemEntities =
            await Directory(fileSystemEntity.path).list().toList();
        foldersFound.add(fileSystemEntity.path);
        var thisFolderProperty = folderProperty.folderProperties
            .firstWhereOrNull(
                (FolderProperty f) => f.path == fileSystemEntity.path);
        if (thisFolderProperty == null) {
          thisFolderProperty =
              FolderProperty(path: fileSystemEntity.path, folderProperties: []);
          folderProperty.folderProperties.add(thisFolderProperty);
        }
        await _updateFolderProperty(
            folderProperty: thisFolderProperty,
            fileSystemEntities: thisFileSystemEntities);
        size += thisFolderProperty.size!;
      }
    }
    folderProperty.folderProperties = folderProperty.folderProperties
        .where((f) => foldersFound.contains(f.path))
        .toList();
    folderProperty.size = size;
    return folderProperty;
  }

  Future<FolderProperty> updateFolderProperty(
      {required String path,
      required Workspace workspace,
      List<FileSystemEntity>? fileSystemEntities,
      bool force = false}) async {
    // region get thisFolderProperty
    workspace.folderProperty ??=
        FolderProperty(path: workspace.path, folderProperties: []);
    FolderProperty? thisFolderProperty = workspace.folderProperty;
    var pathArray = path
        .replaceAll(workspace.path, '')
        .split(Platform.pathSeparator)
        .where((element) => element != '')
        .toList();
    var i = 0;
    while (thisFolderProperty != null && thisFolderProperty.path != path) {
      thisFolderProperty = thisFolderProperty.folderProperties.firstWhereOrNull(
          (f) => f.path.endsWith(Platform.pathSeparator + pathArray[i]));
      i++;
    }
    // endregion
    if (thisFolderProperty == null) {
      return await updateFolderProperty(
          path: workspace.path, workspace: workspace, force: true);
    }
    fileSystemEntities ??= await Directory(path).list().toList();
    if (!force && thisFolderProperty.nbChildren == fileSystemEntities.length) {
      return thisFolderProperty;
    }
    if (thisFolderProperty.path != workspace.path) {
      return await updateFolderProperty(
          path: workspace.path, workspace: workspace, force: true);
    }
    thisFolderProperty = await _updateFolderProperty(
        folderProperty: thisFolderProperty,
        fileSystemEntities: fileSystemEntities);
    workspace.folderProperty = thisFolderProperty;
    WorkspaceService().createUpdateWorkspace(
        oldWorkspace: workspace, newWorkspace: workspace);
    return thisFolderProperty;
  }
}
