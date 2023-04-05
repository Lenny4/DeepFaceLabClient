import 'package:deepfacelab_client/class/appState.dart';
import 'package:redux/redux.dart';

class DarkModeViewModel {
  final bool darkMode;

  DarkModeViewModel({
    required this.darkMode,
  });

  static fromStore(Store<AppState> store) {
    return DarkModeViewModel(
      darkMode: (store.state.storage?.darkMode ?? true),
    );
  }
}
