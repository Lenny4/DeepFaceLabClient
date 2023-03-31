import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DividerWWithTextWidget extends HookWidget {
  final String text;

  DividerWWithTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Text(text),
      const Expanded(child: Divider()),
    ]);
  }
}
