import 'package:flutter/material.dart';
import 'package:redux/redux.dart' as redux;

@immutable
class AppState {
  final bool init;

  const AppState({required this.init});

  factory AppState.initial() {
    return const AppState(init: false);
  }

  AppState copyWith({
    bool? init,
  }) {
    return AppState(init: init ?? this.init);
  }
}

class InitAppStateAction {
  final bool payload;

  const InitAppStateAction({required this.payload});
}

AppState appStateReducer(AppState state, action) {
  if (action is InitAppStateAction) {
    return state.copyWith(init: action.payload);
  }
  return state;
}

final store = redux.Store<AppState>(
  appStateReducer,
  initialState: AppState.initial(),
);
