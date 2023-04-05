import 'package:deepfacelab_client/class/action/switchThemeAction.dart';
import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/viewModel/dark_mode_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';

class SelectThemeWidget extends HookWidget {
  SelectThemeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    switchTheme() {
      store.dispatch(SwitchThemeAction());
    }

    return Row(
      children: [
        const MarkdownBody(selectable: true, data: "## Theme"),
        StoreConnector<AppState, DarkModeViewModel>(
            builder: (BuildContext context, DarkModeViewModel vm) {
              return IconButton(
                icon: Icon(vm.darkMode ? Icons.light_mode : Icons.dark_mode),
                splashRadius: 20,
                onPressed: switchTheme,
              );
            },
            converter: (store) => DarkModeViewModel.fromStore(store)),
      ],
    );
  }
}
