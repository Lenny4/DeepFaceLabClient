import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenIssueWidget extends HookWidget {
  OpenIssueWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'If you encounter a problem please ',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          TextSpan(
            text: 'open an issue',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/Lenny4/DeepFaceLabClient/issues'),
                    mode: LaunchMode.platformDefault);
              },
          ),
          TextSpan(
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            text: '.',
          ),
        ],
      ),
    );
  }
}

class OpenIssue2Widget extends HookWidget {
  OpenIssue2Widget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Open an issue',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/Lenny4/DeepFaceLabClient/issues'),
                    mode: LaunchMode.platformDefault);
              },
          ),
          TextSpan(
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            text: '.',
          ),
        ],
      ),
    );
  }
}
