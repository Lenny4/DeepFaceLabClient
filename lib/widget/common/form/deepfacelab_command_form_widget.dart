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
  TextEditingController controller;
  Question question;

  _QuestionController({required this.controller, required this.question});
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
              .firstWhereOrNull((q) => q.text == question.text);
          if (q != null) {
            localeStorageAnswer = q.answer;
          }
        }
        return _QuestionController(
            controller: TextEditingController(
                text: localeStorageAnswer ??
                    (question.answer == ""
                        ? question.defaultAnswer
                        : question.answer)),
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
            text: questionController.question.text,
            answer: questionController.controller.value.text));
      }
      return await WindowCommandService().saveAndGetLocaleStorageQuestion(
          localeStorageQuestion: localeStorageQuestion,
          workspacePath: workspace.path);
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
        children: questionControllers.value.map((questionController) {
          String label =
              "${questionController.question.text} [${questionController.question.defaultAnswer}]";
          return (TextFormField(
            onFieldSubmitted: (value) {
              onLaunch();
            },
            decoration: InputDecoration(
                hintText: label,
                labelText: label,
                suffixIcon: Tooltip(
                  message: questionController.question.help,
                  child: const Icon(Icons.help),
                )),
            controller: questionController.controller,
            validator: (value) {
              for (var validAnswerRegex
                  in questionController.question.validAnswerRegex) {
                String regex = validAnswerRegex.regex;
                String? match =
                    RegExp(r'' '$regex' '').firstMatch(value!)?.group(0);
                if (match == null) {
                  return validAnswerRegex.errorMessage;
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
