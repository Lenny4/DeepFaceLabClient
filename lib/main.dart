import 'package:deepfacelab_client/screens/dashboard/dashboard_screen.dart';
import 'package:deepfacelab_client/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:side_navigation/side_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: MainView(),
    );
  }
}

class MainView extends HookWidget {
  MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var views = useState<List<Widget>>([
      DashboardScreen(),
      SettingsScreen(),
    ]);

    var selectedIndex = useState<int>(0);

    return Scaffold(
      // The row is needed to display the current view
      body: Row(
        children: [
          /// Pretty similar to the BottomNavigationBar!
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
      ),
    );
  }
}
