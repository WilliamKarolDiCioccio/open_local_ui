import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_local_ui/backend/private/providers/chat.dart';
import 'package:open_local_ui/frontend/widgets/chat_message.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:unicons/unicons.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  ScrollController? _scrollController;
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  final GlobalKey _expandedKey = GlobalKey();
  final GlobalKey _overlayKey = GlobalKey();
  bool _isUserScrolling = false;

  void _scrollToBottomWithAnimation() {
    if (_scrollController != null) {
      _scrollController!.animateTo(
        _scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController == null) return;

    _scrollController!.jumpTo(_scrollController!.position.maxScrollExtent);
  }

  void _scrollListener() {
    if (_scrollController == null) return;

    final atBottom = _scrollController!.position.pixels >=
        _scrollController!.position.maxScrollExtent;

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

  Size _getExpandedSize() {
    final RenderBox renderBox =
        _expandedKey.currentContext?.findRenderObject() as RenderBox;

    return renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollController != null) {
      if (!_isUserScrolling && _scrollController!.hasClients) {
        _scrollToBottom();
      }
    }

    // Listen for screen resizing to update the scroll button position
    MediaQuery.of(context);

    return Column(
      children: [
        Expanded(
          key: _expandedKey,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: DynMouseScroll(
              builder: (context, controller, physics) => ListView.builder(
                physics: physics,
                controller: controller,
                itemCount: context.watch<ChatProvider>().messageCount,
                itemBuilder: (context, index) {
                  if (_scrollController == null) {
                    _scrollController = controller;
                    _scrollController!.addListener(_scrollListener);
                  }

                  final message = context.watch<ChatProvider>().messages[index];

                  return ChatMessageWidget(
                    key: Key(message.uuid),
                    message,
                    controller,
                  ).animate().fadeIn(duration: 300.ms).move(
                        begin: const Offset(-16, 0),
                        curve: Curves.easeOutQuad,
                      );
                },
              ),
            ),
          ),
        ),
        OverlayPortal(
          controller: _overlayPortalController,
          overlayChildBuilder: (context) {
            return Positioned(
              left:
                  _getExpandedOffset().dx + (_getExpandedSize().width / 2) - 16,
              bottom: _getExpandedOffset().dy + 64,
              child: Opacity(
                opacity: 0.75,
                child: IconButton.filled(
                  key: _overlayKey,
                  icon: const Icon(
                    UniconsLine.arrow_down,
                    size: 32.0,
                  ),
                  onPressed: () => _scrollToBottomWithAnimation(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
