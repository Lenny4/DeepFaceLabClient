import 'dart:io';

class PlatformService {
  static String getHomeDirectory() {
    String path = 'HOME';
    if (Platform.isWindows) {
      path = 'HOMEPATH';
    }
    return Platform.environment[path] ?? Platform.pathSeparator;
  }

  static getReleaseFilename() {
    var fileName = 'install_release.sh';
    if (Platform.isWindows) {
      fileName = 'install_release.bat';
    }
    return fileName;
  }
}
