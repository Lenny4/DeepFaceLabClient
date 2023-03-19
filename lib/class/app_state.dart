import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;

  const AppState({required this.init});

  factory AppState.initial() {
    return const AppState(init: false);
  }

  AppState copyWith(newState) {
    return AppState(init: newState['init'] ?? init);
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
