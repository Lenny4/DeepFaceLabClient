import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/release.dart';
import 'package:deepfacelab_client/class/release_asset.dart';
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
    var perPage = useState<int>(30);
    var loadingPage = useState<bool>(true);
    var loadingInstall = useState<int?>(null);
    final packageInfo =
        useSelector<AppState, PackageInfo?>((state) => state.packageInfo);
    final releases =
        useSelector<AppState, List<Release>?>((state) => state.releases);
    final canLoadMoreReleases =
        useSelector<AppState, bool>((state) => state.canLoadMoreReleases);
    final pageRelease =
        useSelector<AppState, int>((state) => state.pageRelease);
    final dispatch = useDispatch<AppState>();

    String getAssetName() {
      if (Platform.isWindows) {
        return 'windows-';
      }
      if (Platform.operatingSystemVersion.contains('20.')) {
        return "ubuntu-20";
      }
      return "ubuntu-22";
    }

    var assetName = useState<String>(getAssetName());

    getReleases() async {
      if (pageRelease == 1 && releases != null) {
        loadingPage.value = false;
        return;
      }
      loadingPage.value = true;
      // https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#list-releases
      var url = Uri.https(
          'api.github.com', '/repos/Lenny4/DeepFaceLabClient/releases', {
        'page': pageRelease.toString(),
        'per_page': perPage.value.toString(),
      });
      var response = await http
          .get(url, headers: {'Accept': 'application/vnd.github+json'});
      List<Release> newReleases = [...?releases];
      bool thisCanLoadMore = false;
      if (response.statusCode == 200) {
        List<dynamic> githubReleases = jsonDecode(response.body);
        for (var githubRelease in githubReleases) {
          newReleases.add(Release.fromJson(githubRelease));
        }
        thisCanLoadMore = githubReleases.length == perPage.value;
      }
      dispatch({
        'releases': newReleases,
        'canLoadMoreReleases': thisCanLoadMore,
      });
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
      var downloadFileName = "newDeepFaceLabRelease.zip";
      await File("$folderPath${Platform.pathSeparator}$downloadFileName")
          .writeAsBytes(response.bodyBytes);
      // region see .github/workflows/release.yml
      var createdFolder = 'DeepFaceLabClient-linux';
      var platform = 'linux';
      var file = 'install_release.sh';
      if (Platform.isWindows) {
        createdFolder = 'DeepFaceLabClient-windows';
        platform = 'windows';
        file = 'install_release.bat';
      }
      Process.run(
          "${Directory.current.path}${Platform.pathSeparator}script${Platform.pathSeparator}$platform${Platform.pathSeparator}$file",
          [
            folderName,
            folderPath,
            downloadFileName,
            execPath,
            createdFolder,
          ],
          runInShell: true);
      await Future.delayed(const Duration(microseconds: 1));
      exit(0);
    }

    useEffect(() {
      getReleases();
      return null;
    }, [pageRelease, perPage.value]);

    return Container(
        child: releases == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const MarkdownBody(selectable: true, data: "# Releases"),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: releases.length,
                      itemBuilder: (context, index) {
                        var isInstalled = packageInfo?.version ==
                            releases[index].tagName.substring(1);
                        ReleaseAsset? asset =
                            releases[index].assets.firstWhereOrNull((asset) {
                          return asset.browserDownloadUrl
                              .contains(assetName.value);
                        });
                        return asset != null
                            ? Card(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(releases[index].tagName),
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
                                            data: releases[index].body),
                                        ElevatedButton.icon(
                                          onPressed: isInstalled ||
                                                  loadingInstall.value != null
                                              ? null
                                              : () {
                                                  installRelease(asset, index);
                                                },
                                          icon: loadingInstall.value == index
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const SizedBox.shrink(),
                                          label: Text(isInstalled
                                              ? "Installed"
                                              : "Install"),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ))
                            : const SizedBox.shrink();
                      },
                    ),
                    if (canLoadMoreReleases == true)
                      ElevatedButton.icon(
                        onPressed: loadingPage.value
                            ? null
                            : () {
                                dispatch({
                                  'pageRelease': pageRelease! + 1,
                                });
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
