import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

// https://docs.flutter.dev/cookbook/persistence/reading-writing-files#complete-example
class LocaleStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/deepfacelab_client_data.json');
  }

  void createFile(File file) {
    file.create();
    file.writeAsString('{}');
  }

  Future<Map> readStorage() async {
    final file = await _localFile;

    if (!file.existsSync()) {
      createFile(file);
    }
    // Read the file
    try {
      return json.decode(await file.readAsString());
    } catch (e) {
      file.delete();
      createFile(file);
      return json.decode(await file.readAsString());
    }
  }

  Future<File> writeStorage(Map data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(json.encode(data));
  }
}
