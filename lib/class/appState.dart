import 'package:deepfacelab_client/class/storage.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;
  final bool hasRequirements;
  final Storage? storage;

  const AppState(
      {required this.init,
      required this.hasRequirements,
      required this.storage});

  factory AppState.initial() {
    return const AppState(init: false, hasRequirements: false, storage: null);
  }

  AppState copyWith(newState) {
    return AppState(
      init: newState['init'] ?? init,
      hasRequirements: newState['hasRequirements'] ?? hasRequirements,
      storage: newState['storage'] ?? storage,
    );
  }
}

AppState appStateReducer(AppState state, action) {
  // if (action is InitAppStateAction) {}
  return state.copyWith(action);
}

final store = redux.Store<AppState>(
  appStateReducer,
  initialState: AppState.initial(),
);
