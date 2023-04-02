import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/screens/dashboard_screen.dart';
import 'package:deepfacelab_client/screens/loading_screen.dart';
import 'package:deepfacelab_client/screens/settings_screen.dart';
import 'package:deepfacelab_client/screens/workspace_screen.dart';
import 'package:deepfacelab_client/service/localeStorageService.dart';
import 'package:deepfacelab_client/viewModel/can_use_deepfacelab_view_model.dart';
import 'package:deepfacelab_client/viewModel/init_view_model.dart';
import 'package:deepfacelab_client/widget/installation/has_requirements_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart' as redux;

void main() {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FilesystemPickerDefaultOptions(
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      child: StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
            theme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: const Route()),
      ),
    );
  }
}

class Route extends HookWidget {
  const Route({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var views = useState<List<Widget>>([
      const DashboardScreen(),
      const WorkspaceScreen(),
      const SettingsScreen(),
    ]);

    var selectedIndex = useState<int>(0);

    return StoreConnector<AppState, InitViewModel>(
        builder: (BuildContext context, InitViewModel vm) {
          return vm.init
              ? Row(
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (context, constraint) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: constraint.maxHeight),
                            child: IntrinsicHeight(
                              // https://api.flutter.dev/flutter/material/NavigationRail-class.html
                              child: NavigationRail(
                                selectedIndex: selectedIndex.value,
                                groupAlignment: -1.0,
                                onDestinationSelected: (int index) {
                                  selectedIndex.value = index;
                                },
                                labelType: NavigationRailLabelType.all,
                                destinations: const [
                                  NavigationRailDestination(
                                    icon: Icon(Icons.dashboard),
                                    selectedIcon: Icon(Icons.dashboard),
                                    label: Text('Dashboard'),
                                  ),
                                  NavigationRailDestination(
                                    icon: Icon(Icons.add),
                                    selectedIcon: Icon(Icons.add),
                                    label: Text('Create a \nworkspace'),
                                  ),
                                  NavigationRailDestination(
                                    icon: Icon(Icons.settings),
                                    selectedIcon: Icon(Icons.settings),
                                    label: Text('Settings'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    // This is the main content.
                    Expanded(
                        child: StoreConnector<AppState,
                                CanUseDeepfacelabViewModel>(
                            builder: (BuildContext context,
                                CanUseDeepfacelabViewModel vm) {
                              return vm.canUseDeepfacelab
                                  ? views.value.elementAt(selectedIndex.value)
                                  : const Scaffold(
                                      body: SingleChildScrollView(
                                        child: HasRequirementsWidget(),
                                      ),
                                    );
                            },
                            converter: (store) =>
                                CanUseDeepfacelabViewModel.fromStore(store))),
                  ],
                )
              : const Scaffold(body: LoadingScreen());
        },
        converter: (store) => InitViewModel.fromStore(store));
  }
}
