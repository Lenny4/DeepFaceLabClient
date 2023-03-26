import 'package:deepfacelab_client/class/app_state.dart';
import 'package:redux/redux.dart';

class HasRequirementsViewModel {
  final bool hasRequirements;

  HasRequirementsViewModel({
    required this.hasRequirements,
  });

  static fromStore(Store<AppState> store) {
    return HasRequirementsViewModel(
      hasRequirements: store.state.hasRequirements,
    );
  }
}
