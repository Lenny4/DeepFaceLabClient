import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/screens/dashboard/dashboard_screen.dart';
import 'package:deepfacelab_client/screens/loading/loading_screen.dart';
import 'package:deepfacelab_client/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart' as redux;
import 'package:side_navigation/side_navigation.dart';

void main() {
  final subscription = store.onChange.listen((AppState appState) {
    print(appState.init);
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
    var views = useState<List<Widget>>([
      const DashboardScreen(),
      const SettingsScreen(),
    ]);

    var selectedIndex = useState<int>(0);

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
          theme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: store.state.init
                ? Row(
                    children: [
                      SideNavigationBar(
                        selectedIndex: selectedIndex.value,
                        items: const [
                          SideNavigationBarItem(
                            icon: Icons.dashboard,
                            label: 'Dashboard',
                          ),
                          SideNavigationBarItem(
                            icon: Icons.settings,
                            label: 'Settings',
                          ),
                        ],
                        onTap: (index) {
                          selectedIndex.value = index;
                        },
                      ),

                      /// Make it take the rest of the available width
                      Expanded(
                        child: views.value.elementAt(selectedIndex.value),
                      )
                    ],
                  )
                : const LoadingScreen(),
          )),
    );
  }
}
