import 'package:deepfacelab_client/class/app_state.dart';
import 'package:deepfacelab_client/viewModel/has_requirements_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';

class InstallationWidget extends HookWidget {
  const InstallationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HasRequirementsViewModel>(
        builder: (BuildContext context, HasRequirementsViewModel vm) {
          return vm.hasRequirements ? Text("okok") : const SizedBox.shrink();
        },
        converter: (store) => HasRequirementsViewModel.fromStore(store));
  }
}
