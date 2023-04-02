import 'package:deepfacelab_client/class/appState.dart';
import 'package:redux/redux.dart';

class InitViewModel {
  final bool init;
  final int selectedScreenIndex;

  InitViewModel({
    required this.init,
    required this.selectedScreenIndex,
  });

  static fromStore(Store<AppState> store) {
    return InitViewModel(
      init: store.state.init,
      selectedScreenIndex: store.state.selectedScreenIndex,
    );
  }
}
