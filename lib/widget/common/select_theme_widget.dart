import 'package:deepfacelab_client/class/action/switch_theme_action.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class SelectThemeWidget extends HookWidget {
  const SelectThemeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkMode =
        useSelector<AppState, bool?>((state) => state.storage?.darkMode);
    final dispatch = useDispatch<AppState>();

    switchTheme() {
      dispatch(SwitchThemeAction());
    }

    return Row(
      children: [
        const MarkdownBody(selectable: true, data: "## Theme"),
        IconButton(
          icon: Icon(darkMode != false ? Icons.light_mode : Icons.dark_mode),
          splashRadius: 20,
          onPressed: switchTheme,
        ),
      ],
    );
  }
}
