import 'package:deepfacelab_client/class/appState.dart';
import 'package:deepfacelab_client/class/device.dart';
import 'package:redux/redux.dart';

class DevicesViewModel {
  final List<Device>? devices;

  DevicesViewModel({
    required this.devices,
  });

  static fromStore(Store<AppState> store) {
    return DevicesViewModel(
      devices: store.state.devices,
    );
  }
}
