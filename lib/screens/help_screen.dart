import 'package:deepfacelab_client/widget/common/self_promotion_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends HookWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText('Help'),
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SelfPromotionWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: MarkdownBody(
                      selectable: true,
                      data: """
## Video tutorials

Watching all videos takes time (about 7h20) but worth it.

Please not that none of these tutorials have been made with DeepFaceLabClient but only with DeepFaceLab.

1. [DeepFace Lab Tutorial: How to make a DeepFake](https://www.youtube.com/watch?v=QSmHho1uHFM) by Druuzil [Dec 17, 2021]
2. [Deepface Live Tutorial - How to make your own Live Model!](https://www.youtube.com/watch?v=_bc3SPbCdW8) by Druuzil [Apr 14, 2022]
3. [Deepface Lab Tutorial - Advanced Training Methods](https://www.youtube.com/watch?v=1Bt5wyGqdk4) by Druuzil [Aug 29, 2022]
                  """,
                      onTapLink: (text, url, title) {
                        if (url != null) launchUrl(Uri.parse(url));
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MarkdownBody(
                      selectable: true,
                      data: """
## DeepfakeVFX

If you don't know where to start we suggest you to visit [deepfakevfx.com](https://www.deepfakevfx.com/)
- [Deepfake Guides](https://www.deepfakevfx.com/guides/)
- [Deepfake Tutorials](https://www.deepfakevfx.com/tutorials/)
- [Deepfake Downloads](https://www.deepfakevfx.com/downloads/)
                  """,
                      onTapLink: (text, url, title) {
                        if (url != null) launchUrl(Uri.parse(url));
                      }),
                ),
              ],
            )),
      ),
    );
  }
}
