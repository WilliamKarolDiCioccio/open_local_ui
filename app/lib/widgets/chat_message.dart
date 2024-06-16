import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:open_local_ui/helpers/datetime.dart';
import 'package:open_local_ui/helpers/snackbar.dart';
import 'package:open_local_ui/models/chat_message.dart';
import 'package:open_local_ui/providers/chat.dart';
import 'package:open_local_ui/widgets/markdown_widget.dart';
import 'package:open_local_ui/widgets/tts_player.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessageWrapper message;

  const ChatMessageWidget(
    this.message, {
    super.key,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _showEditWidget = false;
  bool _showPlayerWidget = false;

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message.text));

    SnackBarHelpers.showSnackBar(
      AppLocalizations.of(context).messageCopiedSnackBar,
      SnackBarType.success,
    );
  }

  void _regenerateMessage() {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackBarType.error,
      );
    } else {
      context.read<ChatProvider>().regenerateMessage(widget.message.uuid);
    }
  }

  void _beginEditingMessage() {
    setState(() {
      _showEditWidget = true;
    });

    _textEditingController.text = widget.message.text;
  }

  void _sendEditedText() {
    if (context.read<ChatProvider>().isGenerating) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackBarType.error,
      );
    } else {
      if (_textEditingController.text.isEmpty) return;

      final userMessage = widget.message as ChatUserMessageWrapper;

      context.read<ChatProvider>().sendEditedMessage(
            userMessage.uuid,
            _textEditingController.text,
            userMessage.imageBytes,
          );

      _cancelEditingMessage();
    }
  }

  void _cancelEditingMessage() {
    setState(() {
      _showEditWidget = false;
    });

    _textEditingController.clear();
  }

  void _showTTSPlayer() {
    final isLastMessage =
        context.read<ChatProvider>().lastMessage!.uuid == widget.message.uuid;

    if (context.read<ChatProvider>().isGenerating && isLastMessage) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).modelIsGeneratingSnackBar,
        SnackBarType.error,
      );
    } else if (widget.message.text.isEmpty) {
      SnackBarHelpers.showSnackBar(
        AppLocalizations.of(context).nothingToSynthesizeSnackBar,
        SnackBarType.error,
      );
    } else {
      setState(() {
        _showPlayerWidget = true;
      });
    }
  }

  void _hideTTSPlayer() {
    setState(() {
      _showPlayerWidget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    late String senderName;
    late IconData senderIconData;

    final chatProvider = context.watch<ChatProvider>();

    switch (widget.message.sender) {
      case ChatMessageSender.user:
        senderIconData = UniconsLine.user;
        senderName = AppLocalizations.of(context).chatUserSender;
        break;
      case ChatMessageSender.model:
        senderIconData = UniconsLine.robot;

        if (widget.message.senderName!.length > 20) {
          senderName = '${widget.message.senderName!.substring(0, 20)}...';
        } else {
          senderName = widget.message.senderName!;
        }

        break;
      case ChatMessageSender.system:
        senderIconData = UniconsLine.eye;
        senderName = AppLocalizations.of(context).chatSystemSender;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.message.sender == ChatMessageSender.user
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(
                senderIconData,
                size: 18.0,
              ),
              const Gap(8),
              Text(
                senderName,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                DateTimeHelpers.formattedDateTime(widget.message.createdAt),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          const Divider(),
          if ((widget.message is ChatUserMessageWrapper))
            if ((widget.message as ChatUserMessageWrapper).imageBytes != null)
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height <= 900.0
                      ? 256.0
                      : 512.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      (widget.message as ChatUserMessageWrapper).imageBytes!,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
          if ((widget.message is ChatUserMessageWrapper))
            if ((widget.message as ChatUserMessageWrapper).imageBytes != null)
              const SizedBox(height: 8.0),
          if (!_showEditWidget)
            MessageMarkdownWidget(
              widget.message.text +
                  (chatProvider.isChatShowStatistics
                      ? _buildStatisticsSummary(widget.message)
                      : ''),
            ),
          const Gap(8.0),
          if (!_showEditWidget &&
              !_showPlayerWidget &&
              !context.watch<ChatProvider>().isGenerating)
            Row(
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).markdownCopyTooltip,
                  onPressed: () => _copyMessage(),
                  icon: const Icon(UniconsLine.copy),
                ),
                const Gap(8),
                IconButton(
                  tooltip: AppLocalizations.of(context).chatReadAloudTooltip,
                  onPressed: () => _showTTSPlayer(),
                  icon: const Icon(Icons.hearing),
                ),
                const Gap(8),
                if (widget.message.sender == ChatMessageSender.model)
                  IconButton(
                    tooltip: AppLocalizations.of(context)
                        .chatRegenerateMessageTooltip,
                    onPressed: () => _regenerateMessage(),
                    icon: const Icon(UniconsLine.repeat),
                  ),
                const Gap(8),
                if (widget.message.sender == ChatMessageSender.user)
                  IconButton(
                    tooltip:
                        AppLocalizations.of(context).chatEditMessageTooltip,
                    onPressed: () => _beginEditingMessage(),
                    icon: const Icon(UniconsLine.edit),
                  ),
              ],
            )
          else if (_showEditWidget)
            Column(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).chatEditFieldHint,
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Neuton',
                  ),
                  autofocus: true,
                  maxLength: 4096,
                  maxLines: null,
                  expands: false,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextButton.icon(
                      label: Text(
                        AppLocalizations.of(context).chatCancelEditButton,
                      ),
                      icon: const Icon(UniconsLine.times),
                      onPressed: () => _cancelEditingMessage(),
                    ),
                    const Gap(8),
                    TextButton.icon(
                      label: Text(
                        AppLocalizations.of(context).chatResendMessageButton,
                      ),
                      icon: const Icon(UniconsLine.message),
                      onPressed: () => _sendEditedText(),
                    ),
                  ],
                ),
              ],
            )
          else if (_showPlayerWidget)
            TTSPlayer(
              text: widget.message.text,
              onPlayerClosed: () => _hideTTSPlayer(),
              onPlaybackRateChanged: (playbackRate) {},
            ),
        ],
      ),
    );
  }

  String _buildStatisticsSummary(ChatMessageWrapper message) {
    if (message.totalTokens == 0) {
      return '';
    }

    final token = message.totalTokens;
    final durationMs = message.totalDuration / 1000 ~/ 1000;
    final tps = (token / (durationMs / 1000)).toStringAsFixed(2);

    return '''


**Token:** $token   **Duration:** $durationMs ms   **Speed:** $tps t/s
 ''';
  }
}
