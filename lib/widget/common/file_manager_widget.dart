import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as p;

class FileManagerWidget extends HookWidget {
  final String initPath;

  FileManagerWidget({Key? key, required this.initPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var folderPath = useState<String>(initPath);
    var fileSystemEntities = useState<List<Map<String, dynamic>>?>(null);

    loadFilesFolders() async {
      fileSystemEntities.value = null;
      var newFileSystemEntities =
          await (Directory(folderPath.value).list()).map((fileSystemEntity) {
        // https://stackoverflow.com/questions/75915594/pathinfo-method-equivalent-for-dart-language#answer-75915804
        String filename = p.basename(fileSystemEntity.path);
        return {
          'filename': filename,
          'directory': fileSystemEntity is Directory,
          'image': filename.contains('.png') ||
              filename.contains('.jpeg') ||
              filename.contains('.jpg'),
        };
      }).toList();
      newFileSystemEntities.sort((a, b) {
        if (a['directory'] == true && b['directory'] == true) {
          return 0;
        }
        if (a['directory'] == true) {
          return -1;
        }
        return 1;
      });
      fileSystemEntities.value = newFileSystemEntities;
    }

    useEffect(() {
      folderPath.value = initPath;
    }, [initPath]);

    useEffect(() {
      loadFilesFolders();
    }, [folderPath.value]);

    return fileSystemEntities.value == null
        ? const Center(child: CircularProgressIndicator())
        : fileSystemEntities.value!.isNotEmpty
            ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("header"),
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
                              message: fileSystemEntities.value![index]
                                  ['filename'],
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    fileSystemEntities.value![index]
                                            ['directory']
                                        ? const Icon(Icons.folder, size: 50)
                                        : fileSystemEntities.value![index]
                                                ['image']
                                            ? Image.asset(
                                                height: 70,
                                                ("${folderPath.value}/${fileSystemEntities.value![index]['filename']}"))
                                            : const Icon(Icons.file_open,
                                                size: 50),
                                    Text(
                                        fileSystemEntities.value![index]
                                            ['filename'],
                                        maxLines: 1),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    const Text("footer 1"),
                  ],
                ),
              )
            : const MarkdownBody(
                selectable: true, data: "# Your directory is empty");
  }
}
