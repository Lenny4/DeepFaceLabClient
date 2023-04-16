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
  String? Function(String)? getAnswer;

  StartProcessConda({required this.command, this.getAnswer});

  @override
  String toString() {
    return command;
  }
}
