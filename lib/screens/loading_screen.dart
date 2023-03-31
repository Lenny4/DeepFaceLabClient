import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:deepfacelab_client/service/localeStorageService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    void initApp() async {
      store.dispatch({
        'init': true,
        'storage': Storage.fromJson(await LocaleStorageService().readStorage())
      });
    }

    useEffect(() {
      initApp();
    }, []);

    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
