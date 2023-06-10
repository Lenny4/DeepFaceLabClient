import 'dart:convert';

import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/release.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class ReleaseWidget extends HookWidget {
  const ReleaseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var page = useState<int>(1);
    var perPage = useState<int>(1);
    var releases = useState<List<Release>?>(null);
    final packageInfo =
        useSelector<AppState, PackageInfo?>((state) => state.packageInfo);

    getReleases() async {
      var url = Uri.https(
          'api.github.com', '/repos/Lenny4/DeepFaceLabClient/releases', {
        'page': page.value.toString(),
        'per_page': perPage.value.toString(),
      });
      var response = await http
          .get(url, headers: {'Accept': 'application/vnd.github+json'});
      List<Release> newReleases = [...?releases.value];
      if (response.statusCode == 200) {
        List<dynamic> githubReleases = jsonDecode(response.body);
        for (var githubRelease in githubReleases) {
          newReleases.add(Release.fromJson(githubRelease));
        }
      }
      releases.value = newReleases;
      print(packageInfo?.version);
    }

    useEffect(() {
      getReleases();
      return null;
    }, [page.value, perPage.value]);

    return Container(
        child: releases.value == null
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: releases.value!.length,
                itemBuilder: (context, index) {
                  var isInstalled = packageInfo?.version ==
                      releases.value![index].tagName.substring(1);
                  return Card(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(releases.value![index].tagName),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, bottom: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MarkdownBody(
                                selectable: true,
                                data: releases.value![index].body),
                            ElevatedButton(
                              onPressed: isInstalled ? null : () {},
                              child: isInstalled
                                  ? const Text("Installed")
                                  : const Text("Install"),
                            )
                          ],
                        ),
                      )
                    ],
                  ));
                },
              ));
  }
}
