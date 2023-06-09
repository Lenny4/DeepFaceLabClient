import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/start_process.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/screens/loading_screen.dart';
import 'package:deepfacelab_client/service/locale_storage_service.dart';
import 'package:deepfacelab_client/service/window_command_service.dart';
import 'package:deepfacelab_client/widget/common/start_process_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';
import 'package:redux/redux.dart' as redux;

class WindowCommandScreen extends HookWidget {
  final redux.Store<AppState> store;
  final WindowCommand windowCommand;

  const WindowCommandScreen(
      {Key? key, required this.store, required this.windowCommand})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: WindowCommand2Screen(windowCommand: windowCommand),
    );
  }
}

class WindowCommand2Screen extends HookWidget {
  final WindowCommand windowCommand;

  const WindowCommand2Screen({Key? key, required this.windowCommand})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final darkMode =
        useSelector<AppState, bool?>((state) => state.storage?.darkMode);
    final init = useSelector<AppState, bool>((state) => state.init);
    final dispatch = useDispatch<AppState>();

    initWidget() async {
      dispatch({
        'init': true,
        'storage': Storage.fromJson(await LocaleStorageService().readStorage()),
      });
    }

    useEffect(() {
      initWidget();
      return null;
    }, []);

    return MaterialApp(
        theme: darkMode != false ? ThemeData.dark() : ThemeData.light(),
        themeMode: darkMode != false ? ThemeMode.dark : ThemeMode.light,
        home: init == true
            ? WindowCommand3Screen(windowCommand: windowCommand)
            : const Scaffold(body: LoadingScreen()));
  }
}

class WindowCommand3Screen extends HookWidget {
  final WindowCommand windowCommand;

  const WindowCommand3Screen({Key? key, required this.windowCommand})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final dispatch = useDispatch<AppState>();

    initWidget() async {
      dispatch({
        'init': true,
        'storage': Storage.fromJson(await LocaleStorageService().readStorage()),
      });
    }

    useEffect(() {
      initWidget();
      return null;
    }, []);

    return Scaffold(
        body: SingleChildScrollView(
      child: StartProcessWidget(
        workspace: windowCommand.workspace,
        autoStart: true,
        closeIcon: false,
        usePrototypeItem: false,
        forceScrollDown: true,
        startProcessesConda: [
          StartProcessConda(
              command: windowCommand.command,
              similarMessageRegex: windowCommand.similarMessageRegex,
              getAnswer: (String questionString) {
                String regex = Questions.autoEnterQuestions;
                String? match = RegExp(r'' '$regex' '')
                    .firstMatch(questionString)
                    ?.group(0);
                if (match != null) {
                  return "\n";
                }
                return windowCommand.questions
                    .firstWhereOrNull((question) =>
                        questionString.contains(question.question))
                    ?.answer;
              })
        ],
        callback: (int code) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            showCloseIcon: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            content: SelectableText(
              code == 0
                  ? 'Command finished with success'
                  : 'Command exit with error code $code',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(days: 1),
          ));
        },
      ),
    ));
  }
}
