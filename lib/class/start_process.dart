class StartProcess {
  String? executable;
  List<String>? arguments;

  @override
  String toString() {
    return "${executable ?? ""} ${arguments?.join(' ') ?? ""}";
  }
}
