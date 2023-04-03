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
    var fileSystemEntities = useState<List<Map<String, dynamic>>>([]);

    loadFilesFolders() async {
      fileSystemEntities.value =
          await (Directory(folderPath.value).list()).map((fileSystemEntity) {
        String filename = p.basename(fileSystemEntity.path);
        return {
          // todo test if fastest that https://stackoverflow.com/questions/75915594/dart-pathinfo-equivalent/75915804#75915804
          'filename': filename,
          'directory': fileSystemEntity is Directory,
          'image': filename.contains('.png') ||
              filename.contains('.jpeg') ||
              filename.contains('.jpg'),
        };
      }).toList();
    }

    useEffect(() {
      folderPath.value = initPath;
    }, [initPath]);

    useEffect(() {
      loadFilesFolders();
    }, [folderPath.value]);

    return fileSystemEntities.value.isNotEmpty
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
                      itemCount: fileSystemEntities.value.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Tooltip(
                          message: fileSystemEntities.value[index]['filename'],
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                fileSystemEntities.value[index]['directory']
                                    ? const Icon(Icons.folder, size: 50)
                                    : fileSystemEntities.value[index]['image']
                                        ? Image.asset(
                                            height: 70,
                                            ("${folderPath.value}/${fileSystemEntities.value[index]['filename']}"))
                                        : const Icon(Icons.file_open, size: 50),
                                Text(
                                    fileSystemEntities.value[index]['filename'],
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
