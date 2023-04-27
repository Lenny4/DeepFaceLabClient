class StartProcess {
  String executable;
  List<String> arguments;
  List<String>? regex;

  StartProcess({required this.executable, required this.arguments, this.regex});

  @override
  String toString() {
    return "$executable ${arguments.join(' ')}";
  }
}

class StartProcessConda {
  String command;
  String? Function(String)? getAnswer;
  List<String>? regex;

  StartProcessConda({required this.command, this.getAnswer, this.regex});

  @override
  String toString() {
    return command;
  }
}
