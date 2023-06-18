import 'dart:io';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:slugify/slugify.dart';

class WorkspaceService {
  static List<String> directories = [
    "${Platform.pathSeparator}data_src",
    "${Platform.pathSeparator}data_src${Platform.pathSeparator}aligned",
    "${Platform.pathSeparator}data_src${Platform.pathSeparator}aligned_debug",
    "${Platform.pathSeparator}data_dst",
    "${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned",
    "${Platform.pathSeparator}data_dst${Platform.pathSeparator}aligned_debug",
    "${Platform.pathSeparator}model",
  ];

  _createWorkspace(Workspace newWorkspace, bool? createFolder) async {
    var storage = store.state.storage;
    if (createFolder == true) {
      storage?.workspaceDefaultPath = newWorkspace.path;
      newWorkspace.path =
          "${newWorkspace.path}${Platform.pathSeparator}${slugify(newWorkspace.name)}";
    }
    reCreateDirectories(workspace: newWorkspace);
    storage?.workspaces = [...?storage.workspaces, newWorkspace];
    int newSelectedScreenIndex = 0;
    int? workspaceLength = storage?.workspaces?.length;
    if (workspaceLength != null) {
      newSelectedScreenIndex = workspaceLength + 1;
    }
    store.dispatch(
        {'selectedScreenIndex': newSelectedScreenIndex, 'storage': storage});
  }

  _updateWorkspace(Workspace oldWorkspace, Workspace newWorkspace) async {
    if (oldWorkspace.path != newWorkspace.path) {
      newWorkspace.path =
          "${newWorkspace.path}${Platform.pathSeparator}${slugify(newWorkspace.name)}";
      (await Process.run('mv', [oldWorkspace.path, newWorkspace.path]));
    }
    var storage = store.state.storage;
    int? index = storage?.workspaces
        ?.indexWhere((workspace) => workspace.path == oldWorkspace.path);
    if (index != null) {
      storage?.workspaces![index] = newWorkspace;
    }
    storage?.workspaces = [...?storage.workspaces];
    store.dispatch({'storage': storage});
  }

  reCreateDirectories({required Workspace? workspace}) async {
    if (workspace == null) {
      return;
    }
    for (var directoryPath in directories) {
      Directory(workspace.path + directoryPath).createSync(recursive: true);
    }
  }

  createUpdateWorkspace(
      {required Workspace? oldWorkspace,
      required Workspace newWorkspace,
      bool? createFolder}) async {
    if (oldWorkspace == null) {
      await _createWorkspace(newWorkspace, createFolder);
    } else {
      await _updateWorkspace(oldWorkspace, newWorkspace);
    }
  }

  importWorkspace({required String path}) async {
    String folderName = p.basename(path);
    await _createWorkspace(Workspace(name: folderName, path: path), false);
  }

  deleteWorkspace(
      {required Workspace workspace, required bool deleteFolder}) async {
    if (deleteFolder) {
      await Directory(workspace.path).delete(recursive: true);
    }
    var storage = store.state.storage;
    storage?.workspaces = [
      ...?storage.workspaces?.where((e) => e.path != workspace.path)
    ];
    store.dispatch({'storage': storage});
  }
}
