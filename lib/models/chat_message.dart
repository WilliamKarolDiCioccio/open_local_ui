import 'dart:typed_data';

import 'package:isar/isar.dart';

part 'chat_message.g.dart';

enum ChatMessageSender { user, model, system }

@collection
class ChatMessageWrapper {
  final Id id = Isar.autoIncrement;

  String text;
  final String createdAt;
  final String uuid;
  @ignore
  final String? senderName;
  @enumerated
  final ChatMessageSender sender;

  ChatMessageWrapper(
    this.text,
    this.createdAt,
    this.uuid,
    this.sender, {
    this.senderName,
  });
}

class ChatSystemMessageWrapper extends ChatMessageWrapper {
  ChatSystemMessageWrapper(
    String text,
    String createdAt,
    String uuid,
  ) : super(
          text,
          createdAt,
          uuid,
          ChatMessageSender.system,
          senderName: 'System',
        );
}

class ChatModelMessageWrapper extends ChatMessageWrapper {
  ChatModelMessageWrapper(
    String text,
    String createdAt,
    String uuid,
    String senderName,
  ) : super(
          text,
          createdAt,
          uuid,
          ChatMessageSender.model,
          senderName: senderName,
        );
}

class ChatUserMessageWrapper extends ChatMessageWrapper {
  @ignore
  final Uint8List? imageBytes;
  final List<String>? filePaths;

  ChatUserMessageWrapper(
    String text,
    String createdAt,
    String uuid, {
    this.imageBytes,
    this.filePaths,
  }) : super(
          text,
          createdAt,
          uuid,
          ChatMessageSender.user,
          senderName: 'User',
        );
}
