import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenIssueWidget extends HookWidget {
  const OpenIssueWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
        selectable: true,
        data:
            "If you encounter a problem please [open an issue](https://github.com/Lenny4/DeepFaceLabClient/issues).",
        onTapLink: (text, url, title) {
          if (url != null) launchUrl(Uri.parse(url));
        });
  }
}

class OpenIssue2Widget extends HookWidget {
  const OpenIssue2Widget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
        selectable: true,
        data:
            "[Open an issue](https://github.com/Lenny4/DeepFaceLabClient/issues).",
        onTapLink: (text, url, title) {
          if (url != null) launchUrl(Uri.parse(url));
        });
  }
}
