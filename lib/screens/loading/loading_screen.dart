import 'package:deepfacelab_client/class/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void  initApp() async {
      var localeStorage = LocaleStorage();
      var test = await localeStorage.readStorage();
      int ok = 0;
    }

    useEffect(() {
      initApp();
    }, []);

    return Center(
      child: Text('LoadingScreen'),
    );
  }
}
