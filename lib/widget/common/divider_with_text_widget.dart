import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DividerWithTextWidget extends HookWidget {
  final String text;

  const DividerWithTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(text),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
