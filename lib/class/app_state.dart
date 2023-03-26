import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;
  final bool hasRequirements;
  final String? deepFaceLabFolder;

  const AppState(
      {required this.init,
      required this.hasRequirements,
      required this.deepFaceLabFolder});

  factory AppState.initial() {
    return const AppState(
        init: false, hasRequirements: false, deepFaceLabFolder: null);
  }

  AppState copyWith(newState) {
    return AppState(
      init: newState['init'] ?? init,
      hasRequirements: newState['hasRequirements'] ?? hasRequirements,
      deepFaceLabFolder: newState['deepFaceLabFolder'] ?? deepFaceLabFolder,
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
