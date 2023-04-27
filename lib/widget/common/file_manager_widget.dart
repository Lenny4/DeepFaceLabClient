import 'dart:io';

import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/screens/workspace_screen.dart';
import 'package:deepfacelab_client/service/workspace_service.dart';
import 'package:deepfacelab_client/widget/common/context_menu_region.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as p;

class _PathItem {
  final String text;
  final String path;

  _PathItem({
    required this.path,
    required this.text,
  });

  @override
  String toString() {
    return '$text: $path';
  }
}

class _FileSystemEntity {
  final String filename;
  final bool directory;
  final bool image;
  final bool video;
  int? selected;
  bool required;

  _FileSystemEntity({
    required this.filename,
    required this.directory,
    required this.image,
    required this.video,
    required this.selected,
    required this.required,
  });
}

// /.pub-cache/hosted/pub.dev/filesystem_picker-3.1.0/lib/src/picker_page.dart
class _FileManagerHeaderWidget extends HookWidget {
  final String rootPath;
  final String folderPath;
  final ValueNotifier<String> pathNotifier;
  final void Function() refresh;

  const _FileManagerHeaderWidget({
    Key? key,
    required this.rootPath,
    required this.folderPath,
    required this.pathNotifier,
    required this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BreadcrumbItem<String?>> getItems() {
      String currentPath = folderPath;
      String dirPath = p.relative(currentPath, from: rootPath);
      final List<String> items =
          (dirPath != '.') ? dirPath.split(Platform.pathSeparator) : [];
      List<_PathItem> pathItems = [];

      String folderName = p.basename(rootPath);
      if (items.isNotEmpty) {
        pathItems.add(_PathItem(path: rootPath, text: folderName));

        String folderPath = rootPath;
        for (var item in items) {
          folderPath = p.join(folderPath, item);
          pathItems.add(_PathItem(path: folderPath, text: item));
        }
      } else {
        pathItems.add(_PathItem(path: rootPath, text: folderName));
      }
      return pathItems
          .map((folderPath) => BreadcrumbItem<String>(
              text: folderPath.text, data: folderPath.path))
          .toList(growable: false);
    }

    var items = useState<List<BreadcrumbItem<String?>>>([]);

    useEffect(() {
      items.value = getItems();
      return null;
    }, [folderPath, rootPath]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Breadcrumbs<String>(
          items: items.value,
          onSelect: (String? value) {
            if (value == null || value == folderPath) {
              return;
            }
            pathNotifier.value = value;
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          splashRadius: 20,
          tooltip: 'Refresh (f5)',
          onPressed: refresh,
        )
      ],
    );
  }
}

class _FileManagerFooterWidget extends HookWidget {
  final int nbSelectedItems;

  const _FileManagerFooterWidget({Key? key, required this.nbSelectedItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox.shrink(),
        SelectableText("$nbSelectedItems items"),
      ],
    );
  }
}

class FileManagerShortcutWidget extends HookWidget {
  const FileManagerShortcutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      title: Text('Shortcuts'),
      tilePadding: EdgeInsets.all(0.0),
      children: <Widget>[
        MarkdownBody(data: """
- `f2`: rename
- `f5`: refresh
- `Ctrl + A`: Select all
- `Ctrl + C`: Copy
- `Ctrl + V`: Paste
- `del`: Delete
- `left click`: Select
- `right click`: Contextual menu
- `Ctrl + click`: Select multiple
- `Shift + click`: Select range
- `double click`: Open file
    """)
      ],
    );
  }
}

class FileManagerMissingFolderWidget extends HookWidget {
  final Workspace? workspace;
  final UpdateChildController controller;
  final Null Function() updateMain;

  const FileManagerMissingFolderWidget(
      {Key? key,
      required this.workspace,
      required this.controller,
      required this.updateMain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    getMissingDirectories() {
      List<String> result = [];
      if (workspace == null) {
        return result;
      }
      for (var directoryPath in WorkspaceService.directories) {
        String fullPath = (workspace?.path ?? "") + directoryPath;
        if (Directory(fullPath).existsSync() == false) {
          result.add(fullPath);
        }
      }
      return result;
    }

    var missingDirectories = useState<List<String>>(getMissingDirectories());

    reCreateDirectories() async {
      if (workspace != null) {
        if (missingDirectories.value.isNotEmpty) {
          await WorkspaceService().reCreateDirectories(workspace: workspace);
          updateMain();
        }
        missingDirectories.value = getMissingDirectories();
      }
    }

    updateFromParent() {
      missingDirectories.value = getMissingDirectories();
    }

    controller.updateFromParent = updateFromParent;

    useEffect(() {
      missingDirectories.value = getMissingDirectories();
      return null;
    }, [workspace]);

    return missingDirectories.value.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: reCreateDirectories,
                  child: const Text("Create missing directories"),
                ),
                IconButton(
                    icon: const Icon(Icons.info),
                    splashRadius: 20,
                    tooltip: 'Information',
                    onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: MarkdownBody(selectable: true, data: """
These folders are missing in your workspaces:

${missingDirectories.value.map((folderPath) => folderPath.replaceFirst(workspace?.path ?? "", "")).join('\n\n')}
                          """),
                          ),
                        ))
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class FileManagerWidget extends HookWidget {
  final String rootPath;
  final UpdateChildController controller;
  final Null Function() updateFileMissing;

  const FileManagerWidget(
      {Key? key,
      required this.rootPath,
      required this.controller,
      required this.updateFileMissing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? homeDirectory = (Platform.environment)['HOME'];

    var folderPath = useState<String>(rootPath);
    var fileSystemEntities = useState<List<_FileSystemEntity>?>(null);
    var nbSelectedItems = useState<int>(0);
    var myFocusNode = useState<FocusNode>(FocusNode());
    var isDragging = useState<bool>(false);
    var isCopyingDrag = useState<bool>(false);
    var loadingForm = useState<bool>(false);
    final formRenameKey = GlobalKey<FormState>();

    loadFilesFolders() async {
      fileSystemEntities.value = null;
      List<_FileSystemEntity> newFileSystemEntities =
          await (Directory(folderPath.value).list()).map((fileSystemEntity) {
        // https://stackoverflow.com/questions/75915594/pathinfo-method-equivalent-for-dart-language#answer-75915804
        String filename = p.basename(fileSystemEntity.path);
        return _FileSystemEntity(
            filename: filename,
            directory: fileSystemEntity is Directory,
            image: filename.endsWith('.png') ||
                filename.endsWith('.jpeg') ||
                filename.endsWith('.jpg'),
            selected: null,
            required: false,
            video: filename.endsWith('.3g2') ||
                filename.endsWith('.3gp') ||
                filename.endsWith('.aaf') ||
                filename.endsWith('.asf') ||
                filename.endsWith('.avchd') ||
                filename.endsWith('.avi') ||
                filename.endsWith('.drc') ||
                filename.endsWith('.flv') ||
                filename.endsWith('.m2v') ||
                filename.endsWith('.m3u8') ||
                filename.endsWith('.m4p') ||
                filename.endsWith('.m4v') ||
                filename.endsWith('.mkv') ||
                filename.endsWith('.mng') ||
                filename.endsWith('.mov') ||
                filename.endsWith('.mp2') ||
                filename.endsWith('.mp4') ||
                filename.endsWith('.mpe') ||
                filename.endsWith('.mpeg') ||
                filename.endsWith('.mpg') ||
                filename.endsWith('.mpv') ||
                filename.endsWith('.mxf') ||
                filename.endsWith('.nsv') ||
                filename.endsWith('.ogg') ||
                filename.endsWith('.ogv') ||
                filename.endsWith('.qt') ||
                filename.endsWith('.rm') ||
                filename.endsWith('.rmvb') ||
                filename.endsWith('.roq') ||
                filename.endsWith('.svi') ||
                filename.endsWith('.vob') ||
                filename.endsWith('.webm') ||
                filename.endsWith('.wmv') ||
                filename.endsWith('.yuv'));
      }).toList();
      newFileSystemEntities.sort((a, b) {
        if (a.directory == true && b.directory == true) {
          return a.filename.compareTo(b.filename);
        }
        if (a.directory == true) {
          return -1;
        }
        if (b.directory == true) {
          return 1;
        }
        return a.filename.compareTo(b.filename);
      });
      if (folderPath.value == rootPath) {
        for (var video in ["data_src", "data_dst"]) {
          if (newFileSystemEntities.indexWhere(
                  (element) => element.filename.contains("$video.")) ==
              -1) {
            newFileSystemEntities.add(_FileSystemEntity(
                filename: video,
                directory: false,
                image: false,
                video: true,
                selected: null,
                required: true));
          }
        }
      }
      fileSystemEntities.value = newFileSystemEntities;
    }

    onTapDownContainer(TapDownDetails tapDownDetails) {
      FocusScope.of(context).requestFocus(myFocusNode.value);
      ContextMenuController.removeAny();
      fileSystemEntities.value = fileSystemEntities.value!.map((e) {
        e.selected = null;
        return e;
      }).toList();
    }

    onPanEndContainer(DragEndDetails dragEndDetails) {
      // todo select files with cursor, use Positioned to show selected area
      // todo https://api.flutter.dev/flutter/widgets/MouseRegion-class.html
      // print("onPanEndContainer");
    }

    selectAll() {
      int now = DateTime.now().millisecondsSinceEpoch;
      fileSystemEntities.value = fileSystemEntities.value!.map((e) {
        if (e.required == false) {
          e.selected = now;
        }
        return e;
      }).toList();
    }

    copyClipboard() async {
      await Clipboard.setData(ClipboardData(
          text: fileSystemEntities.value
              ?.where((element) => element.selected != null)
              .map((e) => "${folderPath.value}/${e.filename}")
              .join('\n')));
    }

    Future<void> copyPath(List<String> froms, String to) async {
      for (var from in froms) {
        var myFile = File(from);
        String thisTo = "$to${Platform.pathSeparator}${p.basename(from)}";
        if (myFile.statSync().type == FileSystemEntityType.directory) {
          await Directory(thisTo).create(recursive: true);
          await for (final file in Directory(from).list()) {
            await copyPath([file.path], thisTo);
          }
        } else {
          await File(from).copy(thisTo);
        }
      }
    }

    pasteClipboard() async {
      var data = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (data != null) {
        isCopyingDrag.value = true;
        await copyPath(data.split('\n').toList(), folderPath.value);
        loadFilesFolders();
        isCopyingDrag.value = false;
      }
    }

    rename() {
      ContextMenuController.removeAny();
      if (nbSelectedItems.value != 1) {
        return;
      }
      var fileSystemEntity = fileSystemEntities.value
          ?.firstWhere((element) => element.selected != null);
      if (fileSystemEntity?.required == true) {
        return;
      }
      final controller =
          TextEditingController(text: fileSystemEntity?.filename);
      final extension = p.extension(fileSystemEntity?.filename ?? "");
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset:
            fileSystemEntity?.filename.replaceFirst(extension, "").length ?? 0,
      );
      validateFormRename() async {
        if (formRenameKey.currentState!.validate()) {
          loadingForm.value = true;
          if (fileSystemEntity?.directory == true) {
            await Directory(
                    "${folderPath.value}${Platform.pathSeparator}${fileSystemEntity?.filename}")
                .rename(
                    "${folderPath.value}${Platform.pathSeparator}${controller.text}");
          } else {
            await File(
                    "${folderPath.value}${Platform.pathSeparator}${fileSystemEntity?.filename}")
                .rename(
                    "${folderPath.value}${Platform.pathSeparator}${controller.text}");
          }
          await loadFilesFolders();
          loadingForm.value = false;
          updateFileMissing();
          return true;
        }
        return false;
      }

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Form(
            key: formRenameKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.text,
              onFieldSubmitted: (value) {
                validateFormRename().then((value) {
                  if (value == true) {
                    Navigator.pop(context);
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field must not be empty';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: !loadingForm.value
                  ? () {
                      validateFormRename().then((value) {
                        if (value == true) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  : null,
              icon: loadingForm.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const SizedBox.shrink(),
              label: const Text("Rename"),
            ),
          ],
        ),
      );
    }

    swapDstSrcVideos() {
      ContextMenuController.removeAny();
      String? srcVideoFilename = fileSystemEntities.value
          ?.firstWhere((element) =>
              element.video && element.filename.contains("data_src."))
          .filename;
      String? dstVideoFilename = fileSystemEntities.value
          ?.firstWhere((element) =>
              element.video && element.filename.contains("data_dst."))
          .filename;
      if (srcVideoFilename != null && dstVideoFilename != null) {
        String temp =
            "${folderPath.value}${Platform.pathSeparator}${srcVideoFilename}_old";
        (File(folderPath.value + Platform.pathSeparator + srcVideoFilename))
            .rename(temp);
        (File(folderPath.value + Platform.pathSeparator + dstVideoFilename))
            .rename(
                folderPath.value + Platform.pathSeparator + srcVideoFilename);
        (File(temp)).rename(
            folderPath.value + Platform.pathSeparator + dstVideoFilename);
      }
      loadFilesFolders();
    }

    delete() {
      ContextMenuController.removeAny();
      var deleteFileSystemEntities = fileSystemEntities.value?.where(
          (element) => element.selected != null && element.required == false);
      if (deleteFileSystemEntities == null ||
          deleteFileSystemEntities.isEmpty) {
        return;
      }
      String deleteSentence = "";
      int nbDirectory =
          deleteFileSystemEntities.where((element) => element.directory).length;
      int nbFiles = deleteFileSystemEntities
          .where((element) => !element.directory)
          .length;
      if (nbDirectory > 0) {
        String directoryString = "directory";
        if (nbDirectory > 1) {
          directoryString = "directories";
        }
        deleteSentence += "$nbDirectory $directoryString";
      }
      if (nbFiles > 0) {
        String fileString = "file";
        if (nbFiles > 1) {
          fileString = "files";
        }
        if (deleteSentence.isNotEmpty) {
          deleteSentence += " and ";
        }
        deleteSentence += "$nbFiles $fileString";
      }
      deleteFilesAndDirectories() async {
        loadingForm.value = true;
        for (var deleteFileSystemEntity in deleteFileSystemEntities) {
          if (deleteFileSystemEntity.directory == true) {
            await Directory(
                    "${folderPath.value}${Platform.pathSeparator}${deleteFileSystemEntity.filename}")
                .delete(recursive: true);
          } else {
            await File(
                    "${folderPath.value}${Platform.pathSeparator}${deleteFileSystemEntity.filename}")
                .delete(recursive: true);
          }
        }
        await loadFilesFolders();
        loadingForm.value = false;
      }

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content:
              SelectableText("Do you really want to delete $deleteSentence"),
          actions: <Widget>[
            ElevatedButton.icon(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: !loadingForm.value
                  ? () {
                      loadingForm.value = true;
                      deleteFilesAndDirectories().then((value) {
                        Navigator.pop(context);
                        updateFileMissing();
                      });
                    }
                  : null,
              icon: loadingForm.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const SizedBox.shrink(),
              label: const Text("Delete"),
            ),
          ],
        ),
      );
    }

    changeDirectory(int index) {
      if (fileSystemEntities.value![index].directory == true) {
        folderPath.value =
            "${folderPath.value}${Platform.pathSeparator}${fileSystemEntities.value![index].filename}";
      }
    }

    onTapCard(int index,
        {Set<LogicalKeyboardKey>? keysPressed, bool? rightClick}) {
      FocusScope.of(context).requestFocus(myFocusNode.value);
      ContextMenuController.removeAny();
      if (fileSystemEntities.value![index].required == true &&
          rightClick != true) {
        FilesystemPicker.openDialog(
          title: 'Select ${fileSystemEntities.value![index].filename} file',
          context: context,
          rootDirectory: Directory(Platform.pathSeparator),
          directory: Directory(homeDirectory ?? Platform.pathSeparator),
          fsType: FilesystemType.file,
          fileTileSelectMode: FileTileSelectMode.wholeTile,
          pickText: 'Validate',
        ).then((value) {
          if (value == null) {
            return;
          }
          String filename = p.basename(value);
          File(value)
              .copy(folderPath.value +
                  Platform.pathSeparator +
                  fileSystemEntities.value![index].filename +
                  p.extension(filename))
              .then((value) => loadFilesFolders());
        });
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      int? lastSelected = fileSystemEntities.value![index].selected;
      if (rightClick != true &&
          lastSelected != null &&
          lastSelected + 500 >= now) {
        if (fileSystemEntities.value![index].directory == true) {
          changeDirectory(index);
        } else {
          String executable = 'xdg-open';
          if (Platform.isWindows) {
            executable = 'start';
          }
          Process.run(executable, [
            folderPath.value +
                Platform.pathSeparator +
                fileSystemEntities.value![index].filename
          ]);
        }
        return;
      }
      bool ctrl = false;
      bool shift = false;
      if (keysPressed != null) {
        ctrl = keysPressed.contains(LogicalKeyboardKey.controlLeft);
        shift = keysPressed.contains(LogicalKeyboardKey.shiftLeft);
      }
      var newFileSystemEntities = fileSystemEntities.value;
      int length = newFileSystemEntities?.length ?? 0;
      if (length > 0) {
        if (shift == true) {
          int firstSelectedIndex =
              newFileSystemEntities?.indexWhere((e) => e.selected != null) ?? 0;
          for (var i = 0; i < length; i++) {
            if ((i >= firstSelectedIndex && i <= index) ||
                (i <= firstSelectedIndex && i >= index)) {
              newFileSystemEntities![i].selected = now;
            } else {
              newFileSystemEntities![i].selected = null;
            }
          }
        } else {
          if (ctrl == false) {
            for (var i = 0; i < length; i++) {
              newFileSystemEntities![i].selected = null;
            }
          }
          newFileSystemEntities![index].selected =
              newFileSystemEntities[index].selected != null ? null : now;
        }
        fileSystemEntities.value = newFileSystemEntities?.toList();
      }
    }

    updateFromParent() {
      loadFilesFolders();
    }

    afterLoadFilesFolders() {
      nbSelectedItems.value = fileSystemEntities.value
              ?.where((element) => element.selected != null)
              .length ??
          0;
    }

    controller.updateFromParent = updateFromParent;

    useEffect(() {
      folderPath.value = rootPath;
      return null;
    }, [rootPath]);

    useEffect(() {
      loadFilesFolders();
      return null;
    }, [folderPath.value]);

    useEffect(() {
      afterLoadFilesFolders();
      return null;
    }, [fileSystemEntities.value]);

    return fileSystemEntities.value == null
        ? const Center(child: CircularProgressIndicator())
        : Expanded(
            child: GestureDetector(
              // https://github.com/flutter/flutter/issues/40548#issuecomment-877083943
              onTapDown: onTapDownContainer,
              onPanEnd: onPanEndContainer,
              child: DropTarget(
                onDragDone: (detail) {
                  isCopyingDrag.value = true;
                  copyPath(detail.files.map((file) => file.path).toList(),
                          folderPath.value)
                      .then((value) {
                    isCopyingDrag.value = false;
                    loadFilesFolders();
                  });
                },
                onDragEntered: (detail) {
                  isDragging.value = true;
                },
                onDragExited: (detail) {
                  isDragging.value = false;
                },
                child: Container(
                  decoration: isDragging.value
                      ? BoxDecoration(
                          border: Border.all(color: Colors.white10, width: 5))
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FileManagerHeaderWidget(
                          pathNotifier: folderPath,
                          folderPath: folderPath.value,
                          rootPath: rootPath,
                          refresh: loadFilesFolders),
                      Expanded(
                        child: CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.keyA,
                                control: true): selectAll,
                            const SingleActivator(LogicalKeyboardKey.f2):
                                rename,
                            const SingleActivator(LogicalKeyboardKey.delete):
                                delete,
                            const SingleActivator(LogicalKeyboardKey.f5):
                                loadFilesFolders,
                            const SingleActivator(LogicalKeyboardKey.keyC,
                                control: true): copyClipboard,
                            const SingleActivator(LogicalKeyboardKey.keyV,
                                control: true): pasteClipboard,
                          },
                          child: Focus(
                            focusNode: myFocusNode.value,
                            autofocus: true,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GridView.builder(
                                    // https://stackoverflow.com/questions/53612200/flutter-how-to-give-height-to-the-childrens-of-gridview-builder
                                    // https://www.youtube.com/watch?v=0blNt4XIi0g
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 110,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: fileSystemEntities.value!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var child = ContextMenuRegion(
                                        beforeShow: () =>
                                            onTapCard(index, rightClick: true),
                                        contextMenuBuilder:
                                            (context, primaryAnchor,
                                                [secondaryAnchor]) {
                                          return AdaptiveTextSelectionToolbar
                                              .buttonItems(
                                            anchors:
                                                TextSelectionToolbarAnchors(
                                              primaryAnchor: primaryAnchor,
                                              secondaryAnchor:
                                                  secondaryAnchor as Offset?,
                                            ),
                                            buttonItems: <
                                                ContextMenuButtonItem>[
                                              if (fileSystemEntities
                                                      .value![index].required ==
                                                  false) ...[
                                                ContextMenuButtonItem(
                                                  onPressed: rename,
                                                  label: 'Rename',
                                                ),
                                                ContextMenuButtonItem(
                                                  onPressed: delete,
                                                  label: 'Delete',
                                                ),
                                              ],
                                              if (folderPath.value ==
                                                      rootPath &&
                                                  ((fileSystemEntities
                                                              .value![index]
                                                              .filename
                                                              .contains(
                                                                  "data_dst.") &&
                                                          fileSystemEntities
                                                              .value![index]
                                                              .video) ||
                                                      (fileSystemEntities
                                                              .value![index]
                                                              .filename
                                                              .contains(
                                                                  "data_src.") &&
                                                          fileSystemEntities
                                                              .value![index]
                                                              .video))) ...[
                                                ContextMenuButtonItem(
                                                  onPressed: swapDstSrcVideos,
                                                  label:
                                                      'Swap dst and src videos',
                                                ),
                                              ]
                                            ],
                                          );
                                        },
                                        child: GestureDetector(
                                          onTap: () => onTapCard(index,
                                              keysPressed: RawKeyboard
                                                  .instance.keysPressed),
                                          child: Card(
                                            color: fileSystemEntities
                                                        .value![index]
                                                        .selected !=
                                                    null
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                fileSystemEntities
                                                        .value![index].required
                                                    ? const Icon(Icons.add,
                                                        size: 50)
                                                    : fileSystemEntities
                                                            .value![index]
                                                            .directory
                                                        ? const Icon(
                                                            Icons.folder,
                                                            size: 50)
                                                        : fileSystemEntities
                                                                .value![index]
                                                                .video
                                                            ? const Icon(
                                                                Icons
                                                                    .video_file,
                                                                size: 50)
                                                            : fileSystemEntities
                                                                    .value![
                                                                        index]
                                                                    .image
                                                                ? Image.asset(
                                                                    height: 70,
                                                                    ("${folderPath.value}/${fileSystemEntities.value![index].filename}"))
                                                                : const Icon(
                                                                    Icons
                                                                        .file_open,
                                                                    size: 50),
                                                Text(
                                                    fileSystemEntities
                                                        .value![index].filename,
                                                    maxLines: 1),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      if (fileSystemEntities
                                              .value![index].filename.length >
                                          13) {
                                        return Tooltip(
                                          message: fileSystemEntities
                                              .value![index].filename,
                                          child: child,
                                        );
                                      }
                                      return child;
                                    }),
                                if (isCopyingDrag.value == true ||
                                    isDragging.value == true)
                                  Positioned(
                                    child: isDragging.value
                                        ? Container(
                                            color: Colors.white10,
                                            child: const IconButton(
                                              icon: Icon(Icons.add),
                                              splashRadius: 20,
                                              iconSize: 60,
                                              onPressed: null,
                                            ),
                                          )
                                        : const CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _FileManagerFooterWidget(
                        nbSelectedItems: nbSelectedItems.value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
