import 'dart:math';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:open_local_ui/layout/page_base.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/providers/model.dart';
import 'package:open_local_ui/widgets/chat_input_field.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:open_local_ui/widgets/chat_toolbar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
    return Consumer<ChatProvider>(
      builder: (context, value, child) => PageBaseLayout(
        body: Column(
          children: [
            const ChatToolbarWidget(),
            const SizedBox(height: 16.0),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: _drawMessagesList(),
              ),
            ),
            Visibility(
              visible: _isScrollButtonVisible,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(
                    UniconsLine.arrow_down,
                    size: 32.0,
                  ),
                  onPressed: _scrollToBottom,
                ),
              ),
            ),
            const FractionallySizedBox(
              widthFactor: 0.6,
              child: ChatInputFieldWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawMessagesList() {
    const List<List<String>> exampleQuestions = [
      [
        "What are some common use cases",
        "for problem-solving skills?",
      ],
      [
        "Plan a birthday party",
        "for your best friend with a surprise element",
      ],
      [
        "Explain the concept of learning from experience",
        "using everyday situations",
      ],
      [
        "Distinguish between teaching and mentoring",
        "and their benefits",
      ],
      [
        "Handle stress in daily life",
        "with effective coping strategies",
      ],
      [
        "Understand the importance of communication skills",
        "in personal and professional life",
      ],
      [
        "Describe the process of decision-making",
        "in complex situations",
      ],
      [
        "List some challenges in personal growth",
        "and strategies to overcome them",
      ],
      [
        "Evaluate the performance of a team",
        "using teamwork metrics",
      ],
      [
        "Discuss the advantages and disadvantages of remote work",
        "for employees and employers",
      ],
      [
        "Address conflicts in relationships",
        "using effective communication",
      ],
      [
        "Explain the significance of empathy",
        "in building strong connections",
      ],
    ];

    final random = Random();

    List<List<String>> randomQuestions =
        List<List<String>>.generate(4, (index) {
      return exampleQuestions[random.nextInt(exampleQuestions.length)];
    });

    List<Widget> questionCells = List<Widget>.generate(
      4,
      (index) {
        return GestureDetector(
          onTap: () {
            final models = context.read<ModelProvider>().models;
            final modelName = models[0].name;
            context.read<ChatProvider>().setModel(modelName);
            final message =
                randomQuestions[index][0] + randomQuestions[index][1];
            context.read<ChatProvider>().sendMessage(message, null);
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
                      fontWeight: FontWeight.w300,
                    ),
                  )),
            ),
          ),
        );
      },
    );

    if (context.read<ChatProvider>().messageCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Ask me whatever you want'),
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
      return ListView.builder(
        controller: _scrollController,
        itemCount: context.watch<ChatProvider>().messageCount,
        itemBuilder: (context, index) {
          final message = context.watch<ChatProvider>().getMessage(index);
          return ChatMessageWidget(message);
        },
      );
    }
  }
}
