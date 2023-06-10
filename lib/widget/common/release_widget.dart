import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/release.dart';
import 'package:deepfacelab_client/class/release_asset.dart';
import 'package:deepfacelab_client/service/process_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    var perPage = useState<int>(30);
    var releases = useState<List<Release>?>(null);
    var canLoadMore = useState<bool>(false);
    var loadingPage = useState<bool>(true);
    var loadingInstall = useState<int?>(null);
    final packageInfo =
        useSelector<AppState, PackageInfo?>((state) => state.packageInfo);

    getReleases() async {
      loadingPage.value = true;
      // https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#list-releases
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
        canLoadMore.value = githubReleases.length == perPage.value;
      }
      releases.value = newReleases;
      loadingPage.value = false;
    }

    installRelease(ReleaseAsset? asset, int index) async {
      if (asset == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          content: const SelectableText(
            'This version is not yet available for your platform. Please restart DeepFaceLabClient and try to install it again in a few minutes',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(days: 1),
        ));
        return;
      }
      loadingInstall.value = index;
      var execPath = Platform.resolvedExecutable;
      var folderPathArray = execPath.split(Platform.pathSeparator);
      folderPathArray.removeLast();
      var folderName = folderPathArray[folderPathArray.length - 1];
      folderPathArray.removeLast();
      var folderPath = folderPathArray.join(Platform.pathSeparator);
      var response = await http.get(Uri.parse(asset.browserDownloadUrl));
      var downloadFileName = ProcessService.getRandomString() + ".zip";
      var file =
          await File("$folderPath${Platform.pathSeparator}$downloadFileName")
              .writeAsBytes(response.bodyBytes);
      var createdFolderArray = (await Process.run('unzip', ['-ol', file.path]))
          .stdout
          .toString()
          .split("\n")[3]
          .split(" ");
      var createdFolder = createdFolderArray[createdFolderArray.length - 1]
          .substring(
              0, createdFolderArray[createdFolderArray.length - 1].length - 1);
      await Process.run('unzip', ['-o', file.path, '-d', folderPath]);
      await Process.run('rm', [file.path]);
      await Process.run(
          'rm', ['-r', folderPath + Platform.pathSeparator + folderName]);
      await Process.run('mv', [
        folderPath + Platform.pathSeparator + createdFolder,
        folderPath + Platform.pathSeparator + folderName
      ]);
      SystemNavigator.pop().then((value) => Process.run(execPath, []));
    }

    useEffect(() {
      getReleases();
      return null;
    }, [page.value, perPage.value]);

    return Container(
        child: releases.value == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const MarkdownBody(selectable: true, data: "# Releases"),
                    ListView.builder(
                      shrinkWrap: true,
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
                              padding: const EdgeInsets.only(
                                  left: 8, bottom: 8, right: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MarkdownBody(
                                      selectable: true,
                                      data: releases.value![index].body),
                                  ElevatedButton.icon(
                                    onPressed: isInstalled ||
                                            loadingInstall.value != null
                                        ? null
                                        : () {
                                            ReleaseAsset? asset = releases
                                                .value![index].assets
                                                .firstWhereOrNull((asset) {
                                              if (Platform.isWindows) {
                                                return asset.browserDownloadUrl
                                                    .contains('windows-v');
                                              }
                                              return asset.browserDownloadUrl
                                                  .contains('linux-v');
                                            });
                                            installRelease(asset, index);
                                          },
                                    icon: loadingInstall.value == index
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const SizedBox.shrink(),
                                    label: Text(
                                        isInstalled ? "Installed" : "Install"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ));
                      },
                    ),
                    if (canLoadMore.value)
                      ElevatedButton.icon(
                        onPressed: loadingPage.value
                            ? null
                            : () {
                                page.value += 1;
                              },
                        icon: loadingPage.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const SizedBox.shrink(),
                        label: const Text('Load more ...'),
                      )
                  ],
                ),
              ));
  }
}
