import 'dart:io';

import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:slugify/slugify.dart';

class WorkspaceService {
  _createWorkspace(Workspace newWorkspace, bool? createFolder) async {
    String path = newWorkspace.path;
    var storage = store.state.storage;
    if (createFolder == true) {
      storage?.workspaceDefaultPath = path;
      path += "/${slugify(newWorkspace.name)}";
      Directory(path).createSync(recursive: true);
      Directory("$path/data_src").createSync(recursive: true);
      Directory("$path/data_src/aligned").createSync(recursive: true);
      Directory("$path/data_src/aligned_debug").createSync(recursive: true);
      Directory("$path/data_dst").createSync(recursive: true);
      Directory("$path/data_dst/aligned").createSync(recursive: true);
      Directory("$path/data_dst/aligned_debug").createSync(recursive: true);
      Directory("$path/model").createSync(recursive: true);
    }
    newWorkspace.path = path;
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
      newWorkspace.path = "${newWorkspace.path}/${slugify(newWorkspace.name)}";
      (await Process.run('mv', [oldWorkspace.path, newWorkspace.path]));
    }
    var storage = store.state.storage;
    int? index = storage?.workspaces
        ?.indexWhere((workspace) => workspace.path == oldWorkspace.path);
    if (index != null) {
      storage?.workspaces![index] = newWorkspace;
    }
    store.dispatch({'storage': storage});
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

  deleteWorkspace(
      {required Workspace workspace, required bool deleteFolder}) async {
    if (deleteFolder) {
      (await Process.run('rm', ['-rf', workspace.path]));
    }
    var storage = store.state.storage;
    storage?.workspaces = [
      ...?storage.workspaces?.where((e) => e.path != workspace.path)
    ];
    store.dispatch({'storage': storage});
  }
}
