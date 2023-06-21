import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfPromotionWidget extends HookWidget {
  const SelfPromotionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
        selectable: true,
        data: """
If you like DeepFaceLabClient please consider adding a star on the [repository](https://github.com/Lenny4/DeepFaceLabClient).
        """,
        onTapLink: (text, url, title) {
          if (url != null) launchUrl(Uri.parse(url));
        });
  }
}
