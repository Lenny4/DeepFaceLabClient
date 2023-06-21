import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/screens/dashboard_screen.dart';
import 'package:deepfacelab_client/screens/help_screen.dart';
import 'package:deepfacelab_client/screens/loading_screen.dart';
import 'package:deepfacelab_client/screens/settings_screen.dart';
import 'package:deepfacelab_client/screens/window_command_screen.dart';
import 'package:deepfacelab_client/screens/workspace_screen.dart';
import 'package:deepfacelab_client/service/locale_storage_service.dart';
import 'package:deepfacelab_client/widget/installation/has_requirements_widget.dart';
import 'package:file_sizes/file_sizes.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart' as redux;
import 'package:url_launcher/url_launcher.dart';

void main(List<String> args) {
  if (args.firstOrNull == 'multi_window') {
    var windowCommand =
        WindowCommand.fromJson(jsonDecode(args[2]) as Map<String, dynamic>);
    runApp(WindowCommandScreen(
      store: store,
      windowCommand: windowCommand,
    ));
    return;
  }
  store.onChange.listen((AppState appState) {
    if (appState.init == true && appState.storage != null) {
      LocaleStorageService().writeStorage(appState.storage!.toJson());
    }
  });

  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends HookWidget {
  final redux.Store<AppState> store;

  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilesystemPickerDefaultOptions(
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      child: StoreProvider<AppState>(
        store: store,
        child: const Root(),
      ),
    );
  }
}

class NavigationRailElement {
  NavigationRailDestination destination;
  Widget widget;

  NavigationRailElement({required this.destination, required this.widget});
}

class Root extends HookWidget {
  const Root({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final darkMode =
        useSelector<AppState, bool?>((state) => state.storage?.darkMode);
    final workspaces = useSelector<AppState, List<Workspace>?>(
        (state) => state.storage?.workspaces);
    final init = useSelector<AppState, bool>((state) => state.init);
    final selectedScreenIndex =
        useSelector<AppState, int>((state) => state.selectedScreenIndex);
    final hasRequirements =
        useSelector<AppState, bool>((state) => state.hasRequirements);
    final deepFaceLabFolder = useSelector<AppState, String?>(
        (state) => state.storage?.deepFaceLabFolder);
    final packageInfo =
        useSelector<AppState, PackageInfo?>((state) => state.packageInfo);
    final dispatch = useDispatch<AppState>();

    List<NavigationRailElement> getViews() {
      List<NavigationRailElement> result = [
        NavigationRailElement(
            destination: const NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            widget: const DashboardScreen()),
        NavigationRailElement(
            destination: const NavigationRailDestination(
              icon: Icon(Icons.add),
              selectedIcon: Icon(Icons.add),
              label: Text('Create a workspace'),
            ),
            widget: const WorkspaceScreen()),
      ];
      if (init == true && workspaces != null) {
        for (Workspace workspace in workspaces) {
          result.add(
            NavigationRailElement(
                destination: NavigationRailDestination(
                  icon: const Icon(Icons.movie),
                  selectedIcon: const Icon(Icons.movie),
                  label: Text(
                      '${workspace.name}\n${FileSize.getSize(workspace.folderProperty?.size ?? 0)}'),
                ),
                widget: WorkspaceScreen(initWorkspace: workspace)),
          );
        }
      }
      result.add(
        NavigationRailElement(
            destination: const NavigationRailDestination(
              icon: Icon(Icons.settings),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
            widget: const SettingsScreen()),
      );
      result.add(
        NavigationRailElement(
            destination: const NavigationRailDestination(
              icon: Icon(Icons.lightbulb),
              selectedIcon: Icon(Icons.lightbulb),
              label: Text('Help'),
            ),
            widget: const HelpScreen()),
      );
      return result;
    }

    var views = useState<List<NavigationRailElement>>(getViews());

    initWidget() async {
      dispatch({
        'init': true,
        'storage': Storage.fromJson(await LocaleStorageService().readStorage()),
        'packageInfo': await PackageInfo.fromPlatform(),
      });
    }

    useEffect(() {
      initWidget();
      return null;
    }, []);

    useEffect(() {
      views.value = getViews();
      return null;
    }, [workspaces]);

    return MaterialApp(
        theme: darkMode != false ? ThemeData.dark() : ThemeData.light(),
        themeMode: darkMode != false ? ThemeMode.dark : ThemeMode.light,
        home: init == true
            ? Row(
                children: <Widget>[
                  LayoutBuilder(
                    builder: (context, constraint) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: constraint.maxHeight, maxWidth: 150),
                          child: IntrinsicHeight(
                            // https://api.flutter.dev/flutter/material/NavigationRail-class.html
                            child: NavigationRail(
                              trailing: Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: MarkdownBody(
                                        selectable: true,
                                        data:
                                            "[${packageInfo?.version ?? ''}](https://github.com/Lenny4/DeepFaceLabClient/releases)",
                                        onTapLink: (text, url, title) {
                                          if (url != null) {
                                            launchUrl(Uri.parse(url));
                                          }
                                        }),
                                  ),
                                ),
                              ),
                              selectedIndex: selectedScreenIndex,
                              groupAlignment: -1.0,
                              onDestinationSelected: (int index) {
                                dispatch({'selectedScreenIndex': index});
                              },
                              labelType: NavigationRailLabelType.all,
                              destinations: views.value
                                  .map((view) => view.destination)
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  // This is the main content.
                  Expanded(
                      child: hasRequirements == true &&
                              deepFaceLabFolder != null
                          ? views.value.elementAt(selectedScreenIndex!).widget
                          : const Scaffold(
                              body: SingleChildScrollView(
                                child: HasRequirementsWidget(),
                              ),
                            )),
                ],
              )
            : const Scaffold(body: LoadingScreen()));
  }
}
