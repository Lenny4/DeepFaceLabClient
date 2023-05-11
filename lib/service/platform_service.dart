import 'dart:io';

class PlatformService {
  static String getHomeDirectory() {
    String path = 'HOME';
    if (Platform.isWindows) {
      path = 'HOMEPATH';
    }
    return Platform.environment[path] ?? Platform.pathSeparator;
  }
}
