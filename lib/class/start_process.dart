class StartProcess {
  String executable;
  List<String> arguments;

  StartProcess({required this.executable, required this.arguments});

  @override
  String toString() {
    return "$executable ${arguments.join(' ')}";
  }
}

class StartProcessConda {
  String command;

  StartProcessConda({required this.command});

  @override
  String toString() {
    return command;
  }
}
