import 'package:deepfacelab_client/class/appState.dart';
import 'package:redux/redux.dart';

class DeepFaceLabFolderViewModel {
  final String? deepFaceLabFolder;

  DeepFaceLabFolderViewModel({
    required this.deepFaceLabFolder,
  });

  static fromStore(Store<AppState> store) {
    return DeepFaceLabFolderViewModel(
      deepFaceLabFolder: store.state.deepFaceLabFolder,
    );
  }
}
