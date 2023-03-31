import 'package:deepfacelab_client/class/appState.dart';
import 'package:redux/redux.dart';

class CanUseDeepfacelabViewModel {
  final bool canUseDeepfacelab;

  CanUseDeepfacelabViewModel({
    required this.canUseDeepfacelab,
  });

  static fromStore(Store<AppState> store) {
    return CanUseDeepfacelabViewModel(
      canUseDeepfacelab: store.state.hasRequirements &&
          store.state.storage!.deepFaceLabFolder != null,
    );
  }
}
