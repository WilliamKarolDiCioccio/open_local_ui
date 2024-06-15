import 'dart:math';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatExampleQuestions extends StatefulWidget {
  const ChatExampleQuestions({super.key});

  @override
  State<ChatExampleQuestions> createState() => _ChatExampleQuestionsState();
}

class _ChatExampleQuestionsState extends State<ChatExampleQuestions> {
  void _sendMessage(String message) {
    if (!context.read<ChatProvider>().isModelSelected) {
      if (context.read<ModelProvider>().modelsCount == 0) {
        return SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).noModelsAvailableSnackBar,
          SnackBarType.error,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackBarType.error,
      );
    }

    context.read<ChatProvider>().sendMessage(message);
  }

  void _addEditableMessage(String message) {
    if (!context.read<ChatProvider>().isModelSelected) {
      if (context.read<ModelProvider>().modelsCount == 0) {
        return SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).noModelsAvailableSnackBar,
          SnackBarType.error,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackBarType.error,
      );
    }

    if (!context.read<ChatProvider>().isSessionSelected) {
      context.read<ChatProvider>().newSession();
    }

    context.read<ChatProvider>().addUserMessage(message, null);
  }

  List<Widget> _generateSuggestionsCells() {
    final List<List<String>> exampleQuestions = [
      [
        AppLocalizations.of(context).suggestionAddressConflictsInRelationshipsPartOne,
        AppLocalizations.of(context).suggestionAddressConflictsInRelationshipsPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionCommonUseCasesForProblemSolvingPartOne,
        AppLocalizations.of(context).suggestionCommonUseCasesForProblemSolvingPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionDecisionMakingInComplexSituationsPartOne,
        AppLocalizations.of(context).suggestionDecisionMakingInComplexSituationsPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionDiscussRemoteWorkAdvantagesPartOne,
        AppLocalizations.of(context).suggestionDiscussRemoteWorkAdvantagesPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionDistinguishTeachingAndMentoringPartOne,
        AppLocalizations.of(context).suggestionDistinguishTeachingAndMentoringPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionEvaluateTeamPerformancePartOne,
        AppLocalizations.of(context).suggestionEvaluateTeamPerformancePartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionExplainEmpathySignificancePartOne,
        AppLocalizations.of(context).suggestionExplainEmpathySignificancePartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionExplainLearningFromExperiencePartOne,
        AppLocalizations.of(context).suggestionExplainLearningFromExperiencePartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionHandleDailyStressPartOne,
        AppLocalizations.of(context).suggestionHandleDailyStressPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionImportanceOfCommunicationPartOne,
        AppLocalizations.of(context).suggestionImportanceOfCommunicationPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionPersonalGrowthChallengesPartOne,
        AppLocalizations.of(context).suggestionPersonalGrowthChallengesPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionPlanSurpriseBirthdayPartyPartOne,
        AppLocalizations.of(context).suggestionPlanSurpriseBirthdayPartyPartTwo,
      ],
    ];

    const exampleQuestionsCount = 4;

    final random = Random();

    final List<List<String>> randomQuestions = List.from(exampleQuestions)
      ..shuffle(random);

    final List<List<String>> choosenQuestions =
        randomQuestions.take(exampleQuestionsCount).toList();

    return List<Widget>.generate(
      exampleQuestionsCount,
      (index) {
        return GestureDetector(
          onTap: () => _sendMessage(
            choosenQuestions[index][0] + choosenQuestions[index][1],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 128,
              width: 256,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdaptiveTheme.of(context).theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    // TODO: Don't know why, but the theme is not applied here. Further investigation needed.
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: randomQuestions[index][0],
                          style: TextStyle(
                            fontFamily: 'Neuton',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdaptiveTheme.of(context).mode.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: randomQuestions[index][1],
                          style: TextStyle(
                            fontFamily: 'Neuton',
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AdaptiveTheme.of(context).mode.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _addEditableMessage(
                      '${choosenQuestions[index][0]} ${choosenQuestions[index][1]}',
                    ),
                    icon: const Icon(UniconsLine.edit),
                  )
                ],
              ),
            )
                .animate(
                  delay: 500.ms + ((Random().nextInt(4) + 1) * 100).ms,
                )
                .scaleXY(begin: 1.1, curve: Curves.easeOutBack)
                .fade(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionCells = _generateSuggestionsCells();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).chatWelcomeMessage,
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 200.ms).move(
                begin: const Offset(0, 160),
                curve: Curves.easeOutQuad,
              ),
          Text(AppLocalizations.of(context).chatSuggestionsPrompt)
              .animate(delay: 300.ms)
              .fadeIn(duration: 200.ms)
              .move(
                begin: const Offset(0, 16),
                curve: Curves.easeOutQuad,
              ),
          const Gap(8.0),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    questionCells[0],
                    questionCells[1],
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    questionCells[2],
                    questionCells[3],
                  ],
                ),
              ],
            ),
          ),
          const Gap(8.0),
          TextButton.icon(
            onPressed: () {
              setState(() {});
            },
            label: Text(
              AppLocalizations.of(context).chatRefreshSuggestions,
            ),
            icon: const Icon(UniconsLine.sync),
          ).animate(delay: 1.seconds).fadeIn(duration: 300.ms).move(
                begin: const Offset(0, 16),
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }
}
