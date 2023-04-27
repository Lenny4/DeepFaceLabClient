import 'package:deepfacelab_client/class/action/switch_theme_action.dart';
import 'package:deepfacelab_client/class/device.dart';
import 'package:deepfacelab_client/class/storage.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;
  final bool hasRequirements;
  final int selectedScreenIndex;
  final List<Device>? devices;
  final Storage? storage;

  const AppState({
    required this.init,
    required this.hasRequirements,
    required this.selectedScreenIndex,
    required this.storage,
    required this.devices,
  });

  factory AppState.initial() {
    return const AppState(
      init: false,
      hasRequirements: false,
      storage: null,
      devices: null,
      selectedScreenIndex: 0,
    );
  }

  AppState copyWith(newState) {
    return AppState(
      init: newState['init'] ?? init,
      hasRequirements: newState['hasRequirements'] ?? hasRequirements,
      selectedScreenIndex:
          newState['selectedScreenIndex'] ?? selectedScreenIndex,
      storage: newState['storage'] ?? storage,
      devices: newState['devices'] ?? devices,
    );
  }
}

AppState appStateReducer(AppState state, action) {
  if (action is SwitchThemeAction) {
    var storage = state.storage;
    if (storage != null) {
      storage.darkMode = !(storage.darkMode ?? true);
    }
    return state;
  } else {
    return state.copyWith(action);
  }
}

final store = redux.Store<AppState>(
  appStateReducer,
  initialState: AppState.initial(),
);
