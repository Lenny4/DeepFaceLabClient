import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;
  final bool hasRequirements;

  const AppState({required this.init, required this.hasRequirements});

  factory AppState.initial() {
    return const AppState(init: false, hasRequirements: false);
  }

  AppState copyWith(newState) {
    return AppState(
      init: newState['init'] ?? init,
      hasRequirements: newState['hasRequirements'] ?? hasRequirements,
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
