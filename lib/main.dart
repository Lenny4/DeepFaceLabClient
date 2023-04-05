import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/screens/dashboard_screen.dart';
import 'package:deepfacelab_client/screens/loading_screen.dart';
import 'package:deepfacelab_client/screens/settings_screen.dart';
import 'package:deepfacelab_client/screens/workspace_screen.dart';
import 'package:deepfacelab_client/service/localeStorageService.dart';
import 'package:deepfacelab_client/viewModel/can_use_deepfacelab_view_model.dart';
import 'package:deepfacelab_client/viewModel/dark_mode_view_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return FilesystemPickerDefaultOptions(
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      child: StoreProvider<AppState>(
        store: store,
        child: StoreConnector<AppState, DarkModeViewModel>(
            builder: (BuildContext context, DarkModeViewModel vm) {
              return MaterialApp(
                  theme: vm.darkMode ? ThemeData.dark() : ThemeData.light(),
                  themeMode: vm.darkMode ? ThemeMode.dark : ThemeMode.light,
                  home: const Root());
            },
            converter: (store) => DarkModeViewModel.fromStore(store)),
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
    final store = StoreProvider.of<AppState>(context);

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
      List<Workspace>? workspaces = store.state.storage?.workspaces;
      if (store.state.init == true && workspaces != null) {
        for (Workspace workspace in workspaces) {
          result.add(
            NavigationRailElement(
                destination: NavigationRailDestination(
                  icon: const Icon(Icons.movie),
                  selectedIcon: const Icon(Icons.movie),
                  label: Text(workspace.name),
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
      return result;
    }

    var views = useState<List<NavigationRailElement>>(getViews());

    return StoreConnector<AppState, InitViewModel>(
        onWillChange: (prevVm, newVm) {
          if (prevVm?.workspaceJson != newVm.workspaceJson) {
            views.value = getViews();
            if (prevVm?.init == true &&
                prevVm?.nbWorkspace != newVm.nbWorkspace) {
              store.dispatch({'selectedScreenIndex': newVm.nbWorkspace + 1});
            }
          }
        },
        builder: (BuildContext context, InitViewModel vm1) {
          return vm1.init
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
                                selectedIndex: vm1.selectedScreenIndex,
                                groupAlignment: -1.0,
                                onDestinationSelected: (int index) {
                                  store
                                      .dispatch({'selectedScreenIndex': index});
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
                        child: StoreConnector<AppState,
                                CanUseDeepfacelabViewModel>(
                            builder: (BuildContext context,
                                CanUseDeepfacelabViewModel vm2) {
                              return vm2.canUseDeepfacelab
                                  ? views.value
                                      .elementAt(vm1.selectedScreenIndex)
                                      .widget
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
