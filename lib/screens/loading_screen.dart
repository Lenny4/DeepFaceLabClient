import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
