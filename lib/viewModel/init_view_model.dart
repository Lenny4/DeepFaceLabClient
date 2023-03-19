import 'package:deepfacelab_client/class/app_state.dart';
import 'package:redux/redux.dart';

class InitViewModel {
  final bool init;

  InitViewModel({
    required this.init,
  });

  static fromStore(Store<AppState> store) {
    return InitViewModel(
      init: store.state.init,
    );
  }
}
