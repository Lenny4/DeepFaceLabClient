import 'dart:io';

import 'package:deepfacelab_client/widget/common/context_menu_region.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart' as Path;

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

  _FileSystemEntity({
    required this.filename,
    required this.directory,
    required this.image,
  });
}

// /.pub-cache/hosted/pub.dev/filesystem_picker-3.1.0/lib/src/picker_page.dart
class FileManagerHeaderWidget extends HookWidget {
  final String rootPath;
  final String path;
  final ValueNotifier<String> pathNotifier;

  FileManagerHeaderWidget(
      {Key? key,
      required this.rootPath,
      required this.path,
      required this.pathNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BreadcrumbItem<String?>> getItems() {
      String currentPath = path;
      String dirPath = Path.relative(currentPath, from: rootPath);
      final List<String> items =
          (dirPath != '.') ? dirPath.split(Platform.pathSeparator) : [];
      List<_PathItem> pathItems = [];

      String folderName = Path.basename(rootPath);
      if (items.isNotEmpty) {
        pathItems.add(_PathItem(path: rootPath, text: folderName));

        String path = rootPath;
        for (var item in items) {
          path = Path.join(path, item);
          pathItems.add(_PathItem(path: path, text: item));
        }
      } else {
        pathItems.add(_PathItem(path: rootPath, text: folderName));
      }
      return pathItems
          .map((path) =>
              BreadcrumbItem<String>(text: path.text, data: path.path))
          .toList(growable: false);
    }

    var items = useState<List<BreadcrumbItem<String?>>>([]);

    useEffect(() {
      items.value = getItems();
    }, [path, rootPath]);

    return Breadcrumbs<String>(
      items: items.value,
      onSelect: (String? value) {
        if (value == null || value == path) {
          return;
        }
        pathNotifier.value = value;
      },
    );
  }
}

class FileManagerFooterWidget extends HookWidget {
  FileManagerFooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SelectableText("footer");
  }
}

class FileManagerWidget extends HookWidget {
  final String rootPath;

  const FileManagerWidget({Key? key, required this.rootPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var folderPath = useState<String>(rootPath);
    var fileSystemEntities = useState<List<_FileSystemEntity>?>(null);

    loadFilesFolders() async {
      fileSystemEntities.value = null;
      List<_FileSystemEntity> newFileSystemEntities =
          await (Directory(folderPath.value).list()).map((fileSystemEntity) {
        // https://stackoverflow.com/questions/75915594/pathinfo-method-equivalent-for-dart-language#answer-75915804
        String filename = Path.basename(fileSystemEntity.path);
        return _FileSystemEntity(
          filename: filename,
          directory: fileSystemEntity is Directory,
          image: filename.contains('.png') ||
              filename.contains('.jpeg') ||
              filename.contains('.jpg'),
        );
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
      fileSystemEntities.value = newFileSystemEntities;
    }

    useEffect(() {
      folderPath.value = rootPath;
    }, [rootPath]);

    useEffect(() {
      loadFilesFolders();
    }, [folderPath.value]);

    return fileSystemEntities.value == null
        ? const Center(child: CircularProgressIndicator())
        : Expanded(
            child: GestureDetector(
              onTap: () => ContextMenuController.removeAny(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FileManagerHeaderWidget(
                      pathNotifier: folderPath,
                      path: folderPath.value,
                      rootPath: rootPath),
                  Expanded(
                    child: GridView.builder(
                        // https://stackoverflow.com/questions/53612200/flutter-how-to-give-height-to-the-childrens-of-gridview-builder
                        // https://www.youtube.com/watch?v=0blNt4XIi0g
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                        ),
                        itemCount: fileSystemEntities.value!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Tooltip(
                            message: fileSystemEntities.value![index].filename,
                            child: ContextMenuRegion(
                              contextMenuBuilder: (context, primaryAnchor,
                                  [secondaryAnchor]) {
                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  anchors: TextSelectionToolbarAnchors(
                                    primaryAnchor: primaryAnchor,
                                    secondaryAnchor: secondaryAnchor as Offset?,
                                  ),
                                  buttonItems: <ContextMenuButtonItem>[
                                    ContextMenuButtonItem(
                                      onPressed: () {
                                        ContextMenuController.removeAny();
                                        // Navigator.of(context).pop();
                                      },
                                      label: 'Back',
                                    ),
                                  ],
                                );
                              },
                              child: GestureDetector(
                                onTap: () => ContextMenuController.removeAny(),
                                onDoubleTap: () {
                                  if (fileSystemEntities
                                          .value![index].directory ==
                                      true) {
                                    folderPath.value =
                                        "${folderPath.value}${Platform.pathSeparator}${fileSystemEntities.value![index].filename}";
                                  }
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      fileSystemEntities.value![index].directory
                                          ? const Icon(Icons.folder, size: 50)
                                          : fileSystemEntities
                                                  .value![index].image
                                              ? Image.asset(
                                                  height: 70,
                                                  ("${folderPath.value}/${fileSystemEntities.value![index].filename}"))
                                              : const Icon(Icons.file_open,
                                                  size: 50),
                                      Text(
                                          fileSystemEntities
                                              .value![index].filename,
                                          maxLines: 1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  FileManagerFooterWidget(),
                ],
              ),
            ),
          );
  }
}
