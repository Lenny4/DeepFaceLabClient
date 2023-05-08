import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/class/start_process.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/screens/loading_screen.dart';
import 'package:deepfacelab_client/service/locale_storage_service.dart';
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
            ? Scaffold(
                body: SingleChildScrollView(
                child: StartProcessWidget(
                  autoStart: true,
                  closeIcon: false,
                  usePrototypeItem: false,
                  forceScrollDown: true,
                  startProcessesConda: [
                    StartProcessConda(
                        command: windowCommand.command,
                        similarMessageRegex: windowCommand.similarMessageRegex,
                        getAnswer: (String questionString) {
                          return windowCommand.questions
                              .firstWhereOrNull((question) =>
                                  questionString.contains(question.question))
                              ?.answer;
                        })
                  ],
                  // callback: (int code) {
                  //   // todo
                  //   print(code);
                  // },
                ),
              ))
            : const Scaffold(body: LoadingScreen()));
  }
}
