class StartProcess {
  String executable;
  List<String> arguments;

  StartProcess({required this.executable, required this.arguments});

  @override
  String toString() {
    return "$executable ${arguments.join(' ')}";
  }
}
