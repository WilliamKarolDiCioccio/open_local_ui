import 'dart:math';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:open_local_ui/widgets/chat_message.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isScrollButtonVisible = false;
      });
    } else {
      setState(() {
        _isScrollButtonVisible = true;
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> exampleQuestions = [
      [
        AppLocalizations.of(context)!.suggestion1part1,
        AppLocalizations.of(context)!.suggestion1part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion2part1,
        AppLocalizations.of(context)!.suggestion2part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion3part1,
        AppLocalizations.of(context)!.suggestion3part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion4part1,
        AppLocalizations.of(context)!.suggestion4part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion5part1,
        AppLocalizations.of(context)!.suggestion5part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion6part1,
        AppLocalizations.of(context)!.suggestion6part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion7part1,
        AppLocalizations.of(context)!.suggestion7part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion8part1,
        AppLocalizations.of(context)!.suggestion8part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion9part1,
        AppLocalizations.of(context)!.suggestion9part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion10part1,
        AppLocalizations.of(context)!.suggestion10part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion11part1,
        AppLocalizations.of(context)!.suggestion11part2,
      ],
      [
        AppLocalizations.of(context)!.suggestion12part1,
        AppLocalizations.of(context)!.suggestion12part2,
      ],
    ];

    const exampleQuestionsCount = 4;

    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        if (context.watch<ChatProvider>().messageCount == 0) {
          final random = Random();

          final List<List<String>> randomQuestions = List.from(exampleQuestions)
            ..shuffle(random);

          final List<List<String>> choosenQuestions =
              randomQuestions.take(exampleQuestionsCount).toList();

          List<Widget> questionCells = List<Widget>.generate(
            exampleQuestionsCount,
            (index) {
              return GestureDetector(
                onTap: () {
                  if (!context.read<ChatProvider>().isModelSelected) {
                    if (context.read<ModelProvider>().modelsCount == 0) {
                      return SnackBarHelper.showSnackBar(
                        AppLocalizations.of(context)!
                            .noModelsAvailableSnackbarText,
                        SnackBarType.error,
                      );
                    } else {
                      final models = context.read<ModelProvider>().models;
                      context.read<ChatProvider>().setModel(models.first.name);
                    }
                  } else if (context.read<ChatProvider>().isGenerating) {
                    return SnackBarHelper.showSnackBar(
                      AppLocalizations.of(context)!
                          .modelIsGeneratingSnackbarText,
                      SnackBarType.error,
                    );
                  }

                  final message =
                      choosenQuestions[index][0] + choosenQuestions[index][1];

                  context.read<ChatProvider>().sendMessage(message);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 128,
                    width: 256,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AdaptiveTheme.of(context).theme.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      title: Text(
                        randomQuestions[index][0],
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        randomQuestions[index][1],
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Neuton',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.chatMessageListText1,
                  style: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 300.ms).move(
                      begin: const Offset(0, 160),
                      curve: Curves.easeOutQuad,
                    ),
                Text(AppLocalizations.of(context)!.chatMessageListText2)
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 200.ms)
                    .move(
                      begin: const Offset(0, 16),
                      curve: Curves.easeOutQuad,
                    ),
                const SizedBox(height: 8.0),
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
              ],
            ),
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: context.watch<ChatProvider>().messageCount,
                    itemBuilder: (context, index) {
                      final message =
                          context.watch<ChatProvider>().messages[index];

                      return ChatMessageWidget(message)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .move(
                            begin: const Offset(-16, 0),
                            curve: Curves.easeOutQuad,
                          );
                    },
                  ),
                ),
              ),
              if (_isScrollButtonVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      UniconsLine.arrow_down,
                      size: 32.0,
                    ),
                    onPressed: _scrollToBottom,
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}
