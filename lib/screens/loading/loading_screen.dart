import 'package:deepfacelab_client/class/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    void initApp() async {
      store.dispatch(InitAppStateAction(payload: true));
    }

    useEffect(() {
      initApp();
    }, []);

    return Center(
      child: Text('LoadingScreen'),
    );
  }
}
