import 'package:flutter/material.dart';

// https://stackoverflow.com/questions/53479942/checkbox-form-validation
class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {super.key,
      Widget? title,
      FormFieldSetter<bool>? onSaved,
      void Function(bool?)? onChanged,
      FormFieldValidator<bool>? validator,
      EdgeInsetsGeometry? contentPadding,
      bool initialValue = false,
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                contentPadding: contentPadding ?? const EdgeInsets.all(0.0),
                title: title,
                value: state.value,
                onChanged: (value) {
                  state.didChange(value);
                  onChanged!(value);
                },
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText ?? "",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}
