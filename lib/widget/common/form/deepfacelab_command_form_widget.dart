import 'package:collection/collection.dart';
import 'package:deepfacelab_client/class/locale_storage_question.dart';
import 'package:deepfacelab_client/class/locale_storage_question_child.dart';
import 'package:deepfacelab_client/class/question.dart';
import 'package:deepfacelab_client/class/window_command.dart';
import 'package:deepfacelab_client/class/workspace.dart';
import 'package:deepfacelab_client/service/window_command_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _QuestionController {
  TextEditingController? controller;
  String? selectValue;
  Question question;

  _QuestionController(
      {required this.question, this.controller, this.selectValue});
}

class DeepfacelabCommandFormWidget extends HookWidget {
  final Workspace workspace;
  final WindowCommand windowCommand;
  final ValueNotifier<Future<LocaleStorageQuestion?> Function()?>
      saveAndGetLocaleStorageQuestion;
  final void Function() onLaunch;

  const DeepfacelabCommandFormWidget(
      {Key? key,
      required this.workspace,
      required this.windowCommand,
      required this.saveAndGetLocaleStorageQuestion,
      required this.onLaunch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formKey = useState<GlobalKey<FormState>>(GlobalKey<FormState>());

    List<_QuestionController> getQuestionControllers() {
      LocaleStorageQuestion? localeStorageQuestion = workspace
          .localeStorageQuestions
          ?.firstWhereOrNull((LocaleStorageQuestion localeStorageQuestion) =>
              localeStorageQuestion.key == windowCommand.key);
      return windowCommand.questions.map((question) {
        String? localeStorageAnswer;
        if (localeStorageQuestion != null) {
          var q = localeStorageQuestion.questions
              .firstWhereOrNull((q) => q.question == question.question);
          if (q != null) {
            localeStorageAnswer = q.answer;
          }
        }
        var thisAnswer = localeStorageAnswer ??
            (question.answer == "" ? question.defaultAnswer : question.answer);
        if (question.options != null) {
          return _QuestionController(
              selectValue: thisAnswer, question: question);
        }
        return _QuestionController(
            controller: TextEditingController(text: thisAnswer),
            question: question);
      }).toList();
    }

    var questionControllers =
        useState<List<_QuestionController>>(getQuestionControllers());

    Future<LocaleStorageQuestion?> onSubmit() async {
      if (!formKey.value.currentState!.validate()) {
        return null;
      }
      formKey.value.currentState?.save();
      LocaleStorageQuestion localeStorageQuestion =
          LocaleStorageQuestion(key: windowCommand.key, questions: []);
      for (var questionController in questionControllers.value) {
        localeStorageQuestion.questions.add(LocaleStorageQuestionChild(
            question: questionController.question.question,
            answer: (questionController.controller != null
                    ? questionController.controller!.value.text
                    : questionController.selectValue) ??
                ""));
      }
      return await WindowCommandService().saveAndGetLocaleStorageQuestion(
          localeStorageQuestion: localeStorageQuestion,
          workspacePath: workspace.path);
    }

    bool isNumeric(String s) {
      return double.tryParse(s) != null;
    }

    int? getInteger(String? s) {
      if (s == null) {
        return null;
      }
      if (!isNumeric(s)) {
        return null;
      }
      num value = num.parse(s);
      if (value is! int) {
        return null;
      }
      return value;
    }

    useEffect(() {
      questionControllers.value = getQuestionControllers();
      Future.delayed(
          // todo improve by removing Future.delayed
          const Duration(milliseconds: 50),
          () => saveAndGetLocaleStorageQuestion.value = onSubmit);
      return null;
    }, [windowCommand]);

    return Form(
      key: formKey.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questionControllers.value
            .mapIndexed((indexQuestionController, questionController) {
          String label =
              "${questionController.question.text} [${questionController.question.defaultAnswer}]";
          var inputDecoration = InputDecoration(
              hintText: label,
              labelText: label,
              suffixIcon: Tooltip(
                message: questionController.question.help,
                child: const Icon(Icons.help),
              ));
          return (questionController.question.options != null
              ? Column(
                  children: [
                    (DropdownButtonFormField<String>(
                      decoration: inputDecoration,
                      value: questionController.selectValue,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_downward),
                      onChanged: (String? value) {
                        questionControllers
                            .value[indexQuestionController].selectValue = value;
                        questionControllers.value =
                            questionControllers.value.toList();
                      },
                      items: questionController.question.options
                          ?.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                  ],
                )
              : TextFormField(
                  onFieldSubmitted: (value) {
                    onLaunch();
                  },
                  decoration: inputDecoration,
                  controller: questionController.controller,
                  validator: (value) {
                    if (questionController.question.validAnswerRegex == null) {
                      return null;
                    }
                    for (var validAnswerRegex
                        in questionController.question.validAnswerRegex!) {
                      if (validAnswerRegex.regex != null) {
                        String regex = validAnswerRegex.regex!;
                        String? match = RegExp(r'' '$regex' '')
                            .firstMatch(value!)
                            ?.group(0);
                        if (match == null) {
                          return validAnswerRegex.errorMessage;
                        }
                      } else {
                        var number = getInteger(value);
                        if (number == null ||
                            (validAnswerRegex.min != null &&
                                number < validAnswerRegex.min!) ||
                            (validAnswerRegex.max != null &&
                                number > validAnswerRegex.max!)) {
                          return validAnswerRegex.errorMessage;
                        }
                      }
                    }
                    return null;
                  },
                ));
        }).toList(),
      ),
    );
  }
}
