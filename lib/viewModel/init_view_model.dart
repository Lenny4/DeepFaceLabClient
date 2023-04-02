import 'package:deepfacelab_client/class/appState.dart';
import 'package:redux/redux.dart';

class InitViewModel {
  final bool init;
  final int selectedScreenIndex;
  final String? workspaceJson;
  final int nbWorkspace;

  InitViewModel({
    required this.init,
    required this.selectedScreenIndex,
    required this.workspaceJson,
    required this.nbWorkspace,
  });

  static fromStore(Store<AppState> store) {
    return InitViewModel(
      init: store.state.init,
      selectedScreenIndex: store.state.selectedScreenIndex,
      nbWorkspace: store.state.storage?.workspaces?.length ?? 0,
      workspaceJson: store.state.storage?.workspaces
          ?.map((workspace) => workspace.toJson())
          .toString(),
    );
  }
}
