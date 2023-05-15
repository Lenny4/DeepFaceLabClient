import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

// https://docs.flutter.dev/cookbook/persistence/reading-writing-files#complete-example
class LocaleStorageService {
  Future<String> get _localPath async {
    if (Platform.isWindows) {
      var directory = Directory(
          "${Platform.pathSeparator}ProgramData${Platform.pathSeparator}DeepFaceLabClient");
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      return directory.path;
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path${Platform.pathSeparator}.deepfacelab_client_data.json');
  }

  createFile(File file) async {
    await file.create();
    await file.writeAsString('{}');
  }

  Future<Map<String, dynamic>> readStorage() async {
    final file = await _localFile;

    if (!(await file.exists())) {
      await createFile(file);
    }
    // Read the file
    try {
      return json.decode(await file.readAsString());
    } catch (e) {
      await file.delete();
      await createFile(file);
      return json.decode(await file.readAsString());
    }
  }

  Future<File> writeStorage(Map data) async {
    final file = await _localFile;

    // Write the file
    return await file.writeAsString(json.encode(data));
  }
}
