import 'dart:math';

import 'package:flutter/material.dart';


import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/backend/providers/chat.dart';
import 'package:open_local_ui/backend/providers/model.dart';
import 'package:open_local_ui/frontend/helpers/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatExampleQuestions extends StatefulWidget {
  const ChatExampleQuestions({super.key});

  @override
  State<ChatExampleQuestions> createState() => _ChatExampleQuestionsState();
}

class _ChatExampleQuestionsState extends State<ChatExampleQuestions> {
  List<Widget> _generateSuggestionsCards() {
    final List<List<String>> exampleQuestions = [
      [
        AppLocalizations.of(context)
            .suggestionAddressConflictsInRelationshipsPartOne,
        AppLocalizations.of(context)
            .suggestionAddressConflictsInRelationshipsPartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionCommonUseCasesForProblemSolvingPartOne,
        AppLocalizations.of(context)
            .suggestionCommonUseCasesForProblemSolvingPartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionDecisionMakingInComplexSituationsPartOne,
        AppLocalizations.of(context)
            .suggestionDecisionMakingInComplexSituationsPartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionDiscussRemoteWorkAdvantagesPartOne,
        AppLocalizations.of(context)
            .suggestionDiscussRemoteWorkAdvantagesPartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionDistinguishTeachingAndMentoringPartOne,
        AppLocalizations.of(context)
            .suggestionDistinguishTeachingAndMentoringPartTwo,
      ],
      [
        AppLocalizations.of(context).suggestionEvaluateTeamPerformancePartOne,
        AppLocalizations.of(context).suggestionEvaluateTeamPerformancePartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionExplainEmpathySignificancePartOne,
        AppLocalizations.of(context)
            .suggestionExplainEmpathySignificancePartTwo,
      ],
      [
        AppLocalizations.of(context)
            .suggestionExplainLearningFromExperiencePartOne,
        AppLocalizations.of(context)
            .suggestionExplainLearningFromExperiencePartTwo,
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
        return ChatExampleQuestionCard(
          question: choosenQuestions[index][0],
          questionDetails: randomQuestions[index][1],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionCards = _generateSuggestionsCards();

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
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: questionCards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.85,
              ),
              itemBuilder: (context, index) {
                return questionCards[index];
              },
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

class ChatExampleQuestionCard extends StatefulWidget {
  final String question;
  final String questionDetails;

  const ChatExampleQuestionCard({
    super.key,
    required this.question,
    required this.questionDetails,
  });

  @override
  State<ChatExampleQuestionCard> createState() =>
      _ChatExampleQuestionCardState();
}

class _ChatExampleQuestionCardState extends State<ChatExampleQuestionCard> {
  bool _isHovering = false;

  void _sendMessage(String message) async {
    if (!context.read<ChatProvider>().isModelSelected) {
      if (context.read<ModelProvider>().modelsCount == 0) {
        return SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).snackBarErrorTitle,
          AppLocalizations.of(context).noModelsAvailableSnackBar,
          SnackbarContentType.failure,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        await context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    }

    // ignore: use_build_context_synchronously
    context.read<ChatProvider>().sendMessage(message);
  }

  void _addEditableMessage(String message) {
    if (!context.read<ChatProvider>().isModelSelected) {
      if (context.read<ModelProvider>().modelsCount == 0) {
        return SnackBarHelpers.showSnackBar(
          AppLocalizations.of(context).snackBarErrorTitle,
          AppLocalizations.of(context).noModelsAvailableSnackBar,
          SnackbarContentType.failure,
        );
      } else {
        final models = context.read<ModelProvider>().models;
        context.read<ChatProvider>().setModel(models.first.name);
      }
    } else if (context.read<ChatProvider>().isGenerating) {
      return SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).snackBarErrorTitle,
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackbarContentType.failure,
      );
    }

    if (!context.read<ChatProvider>().isSessionSelected) {
      context.read<ChatProvider>().newSession();
    }

    context.read<ChatProvider>().addUserMessage(message, null);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => null,
      onHover: (value) {
        setState(() => _isHovering = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        padding: EdgeInsets.all(_isHovering ? 12.0 : 8.0),
        child: GestureDetector(
          onTap: () => _sendMessage(
            '${widget.question} ${widget.questionDetails}',
          ),
          child: Container(
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
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.question,
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
                        text: widget.questionDetails,
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
                    '${widget.question} ${widget.questionDetails}',
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
      ),
    );
  }
}
