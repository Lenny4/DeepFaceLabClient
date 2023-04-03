import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FileManagerWidget extends HookWidget {
  final String initPath;

  FileManagerWidget({Key? key, required this.initPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var path = useState<String>(initPath);
    var fileSystemEntities = useState<List<Map<String, dynamic>>>([]);

    loadFilesFolders() async {
      fileSystemEntities.value =
          await (Directory(path.value).list()).map((fileSystemEntity) {
        return {
          'path': fileSystemEntity.path,
          'directory': fileSystemEntity is Directory,
        };
      }).toList();
    }

    useEffect(() {
      path.value = initPath;
    }, [initPath]);

    useEffect(() {
      loadFilesFolders();
    }, [path.value]);

    return fileSystemEntities.value.isNotEmpty
        ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("header"),
                Expanded(
                  child: ListView.builder(
                    itemCount: fileSystemEntities.value.length,
                    shrinkWrap: true,
                    prototypeItem: ListTile(
                      title: Text(fileSystemEntities.value.first['path']),
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(fileSystemEntities.value[index]['path']),
                      );
                    },
                  ),
                ),
                const Text("footer 1"),
              ],
            ),
          )
        : const MarkdownBody(
            selectable: true, data: "# Your directory is empty");
  }
}
