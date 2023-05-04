class StartProcess {
  String executable;
  List<String> arguments;
  List<String>? similarMessageRegex;

  StartProcess(
      {required this.executable,
      required this.arguments,
      this.similarMessageRegex});

  @override
  String toString() {
    return "$executable ${arguments.join(' ')}";
  }
}

class StartProcessConda {
  String command;
  String? Function(String)? getAnswer;
  List<String>? similarMessageRegex;

  StartProcessConda(
      {required this.command, this.getAnswer, this.similarMessageRegex});

  @override
  String toString() {
    return command;
  }
}
