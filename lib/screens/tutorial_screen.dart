import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialScreen extends HookWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText('Tutorials'),
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: MarkdownBody(selectable: true, data: """
Watching all videos takes time (about 7h20) but worth it.

Please not that none of these tutorials have been made with DeepFaceLabClient but only with DeepFaceLab.
                  """),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '1) ',
                        ),
                        TextSpan(
                          text: "DeepFace Lab Tutorial: How to make a DeepFake",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      'https://www.youtube.com/watch?v=QSmHho1uHFM'),
                                  mode: LaunchMode.platformDefault);
                            },
                        ),
                        const TextSpan(
                          text: ' by Druuzil [Dec 17, 2021]',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '2) ',
                        ),
                        TextSpan(
                          text:
                              "Deepface Live Tutorial - How to make your own Live Model!",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      'https://www.youtube.com/watch?v=_bc3SPbCdW8'),
                                  mode: LaunchMode.platformDefault);
                            },
                        ),
                        const TextSpan(
                          text: ' by Druuzil [Apr 14, 2022]',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '3) ',
                        ),
                        TextSpan(
                          text:
                              "Deepface Lab Tutorial - Advanced Training Methods",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      'https://www.youtube.com/watch?v=1Bt5wyGqdk4&t=2s'),
                                  mode: LaunchMode.platformDefault);
                            },
                        ),
                        const TextSpan(
                          text: ' by Druuzil [Aug 29, 2022]',
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
