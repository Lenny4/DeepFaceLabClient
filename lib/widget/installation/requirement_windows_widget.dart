import 'package:deepfacelab_client/class/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux_hooks/flutter_redux_hooks.dart';

class RequirementWindowsWidget extends HookWidget {
  const RequirementWindowsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dispatch = useDispatch<AppState>();

    updateRequirements() async {
      dispatch({
        'hasRequirements': true,
      });
    }

    useEffect(() {
      updateRequirements();
      return null;
    }, []);

    return const SizedBox.shrink();
  }
}
