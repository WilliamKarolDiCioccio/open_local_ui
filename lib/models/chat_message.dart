import 'dart:typed_data';

import 'package:isar/isar.dart';

part 'chat_message.g.dart';

enum ChatMessageSender { user, model, system }

@collection
class ChatMessageWrapper {
  final Id id = Isar.autoIncrement;
  String text;
  @ignore
  final Uint8List? imageBytes;
  final String dateTime;
  final String uuid;
  @ignore
  final String? senderName;
  @enumerated
  final ChatMessageSender sender;

  ChatMessageWrapper(this.text, this.dateTime, this.uuid, this.sender,
      {this.senderName, this.imageBytes});
}
