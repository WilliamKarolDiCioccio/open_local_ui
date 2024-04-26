import 'dart:typed_data';

enum ChatMessageSender { user, model, system }

class ChatMessageWrapper {
  String text;
  final Uint8List? imageBytes;
  final String dateTime;
  final String uuid;
  final String? senderName;
  final ChatMessageSender sender;

  ChatMessageWrapper(this.text, this.dateTime, this.uuid, this.sender,
      {this.senderName, this.imageBytes});

  factory ChatMessageWrapper.fromJson(Map<String, dynamic> json) {
    return ChatMessageWrapper(
      json['text'] as String,
      json['dateTime'] as String,
      json['uuid'] as String,
      ChatMessageSender.values[json['sender'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'dateTime': dateTime,
      'uuid': uuid,
      'senderName': senderName,
      'sender': sender.index,
    };
  }
}
