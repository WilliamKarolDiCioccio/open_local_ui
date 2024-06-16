import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/widgets/chat_message.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  final GlobalKey _expandedKey = GlobalKey();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomWithAnimation() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _scrollListener() {
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent;

    if (atBottom) {
      setState(() {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _overlayPortalController.hide(),
        );

        _isUserScrolling = false;
      });
    } else {
      setState(() {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _overlayPortalController.show(),
        );

        _isUserScrolling = true;
      });
    }
  }

  Offset _getExpandedOffset() {
    final RenderBox renderBox =
        _expandedKey.currentContext?.findRenderObject() as RenderBox;

    return renderBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserScrolling && _scrollController.hasClients) {
      _scrollToBottom();
    }

    return Column(
      children: [
        Expanded(
          key: _expandedKey,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: context.watch<ChatProvider>().messageCount,
              itemBuilder: (context, index) {
                final message = context.watch<ChatProvider>().messages[index];

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
        OverlayPortal(
          controller: _overlayPortalController,
          overlayChildBuilder: (context) {
            return Positioned(
              left: _getExpandedOffset().dx,
              bottom: _getExpandedOffset().dy + 24,
              child: ElevatedButton.icon(
                label: Text(
                  AppLocalizations.of(context).scrollToBottomButton,
                ),
                icon: const Icon(
                  UniconsLine.arrow_down,
                  size: 32.0,
                ),
                onPressed: () => _scrollToBottomWithAnimation(),
              ),
            );
          },
        ),
      ],
    );
  }
}
