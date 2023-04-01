import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DividerWithTextWidget extends HookWidget {
  final String text;

  DividerWithTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Text(text),
      const Expanded(child: Divider()),
    ]);
  }
}
