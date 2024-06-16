import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.g.dart';

class ImageBytesJSONConverter implements JsonConverter<Uint8List?, Object?> {
  const ImageBytesJSONConverter();

  @override
  Uint8List? fromJson(Object? json) {
    if (json is String) {
      final base64String = jsonDecode(json);
      return base64Decode(base64String);
    } else {
      return null;
    }
  }

  @override
  Object? toJson(Uint8List? object) {
    if (object != null) {
      final base64String = base64Encode(object);
      return jsonEncode(base64String);
    } else {
      return null;
    }
  }
}

enum ChatMessageSender { user, model, system }

class ChatMessageSenderJSONConverter
    implements JsonConverter<ChatMessageSender, String> {
  const ChatMessageSenderJSONConverter();

  @override
  ChatMessageSender fromJson(String json) {
    switch (json) {
      case 'user':
        return ChatMessageSender.user;
      case 'model':
        return ChatMessageSender.model;
      case 'system':
        return ChatMessageSender.system;
      default:
        throw ArgumentError.value(json, 'json', 'Invalid ChatMessageSender');
    }
  }

  @override
  String toJson(ChatMessageSender object) {
    switch (object) {
      case ChatMessageSender.user:
        return 'user';
      case ChatMessageSender.model:
        return 'model';
      case ChatMessageSender.system:
        return 'system';
    }
  }
}

// NOTE: named with 'Wrapper' suffix to avoid conflict with LangChain
@JsonSerializable()
class ChatMessageWrapper {
  String text;
  final DateTime createdAt;
  final String uuid;
  final String? senderName;

  // Metadata
  int totalDuration;
  int loadDuration;
  int promptEvalCount;
  int promptEvalDuration;
  int evalCount;
  int evalDuration;

  // Usage
  int promptTokens;
  int responseTokens;
  int totalTokens;

  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
    toJson: _senderToJson,
    fromJson: _senderFromJson,
  )
  final ChatMessageSender sender;

  ChatMessageWrapper(
    this.text,
    this.createdAt,
    this.uuid,
    this.sender, {
    this.senderName,
    this.totalDuration = 0,
    this.loadDuration = 0,
    this.promptEvalCount = 0,
    this.promptEvalDuration = 0,
    this.evalCount = 0,
    this.evalDuration = 0,
    this.promptTokens = 0,
    this.responseTokens = 0,
    this.totalTokens = 0,
  });

  factory ChatMessageWrapper.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageWrapperToJson(this);

  static ChatMessageSender _senderFromJson(String json) =>
      const ChatMessageSenderJSONConverter().fromJson(json);

  static String _senderToJson(ChatMessageSender object) =>
      const ChatMessageSenderJSONConverter().toJson(object);
}

@JsonSerializable()
class ChatSystemMessageWrapper extends ChatMessageWrapper {
  ChatSystemMessageWrapper(
    String text,
    DateTime createdAt,
    String uuid,
  ) : super(
          text,
          createdAt,
          uuid,
          ChatMessageSender.system,
          senderName: 'System',
        );

  factory ChatSystemMessageWrapper.fromJson(Map<String, dynamic> json) =>
      _$ChatSystemMessageWrapperFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatSystemMessageWrapperToJson(this);
}

@JsonSerializable()
class ChatModelMessageWrapper extends ChatMessageWrapper {
  ChatModelMessageWrapper(
    String text,
    DateTime createdAt,
    String uuid,
    String senderName,
  ) : super(
          text,
          createdAt,
          uuid,
          ChatMessageSender.model,
          senderName: senderName,
        );

  factory ChatModelMessageWrapper.fromJson(Map<String, dynamic> json) =>
      _$ChatModelMessageWrapperFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatModelMessageWrapperToJson(this);
}

@JsonSerializable()
class ChatUserMessageWrapper extends ChatMessageWrapper {
  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
    includeIfNull: true,
    fromJson: _imageBytesFromJson,
    toJson: _imageBytesToJson,
  )
  final Uint8List? imageBytes;

  final List<String>? filePaths;

  ChatUserMessageWrapper(
    String text,
    DateTime createdAt,
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

  factory ChatUserMessageWrapper.fromJson(Map<String, dynamic> json) =>
      _$ChatUserMessageWrapperFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatUserMessageWrapperToJson(this);

  static Uint8List? _imageBytesFromJson(Object? json) =>
      const ImageBytesJSONConverter().fromJson(json);

  static Object? _imageBytesToJson(Uint8List? imageBytes) =>
      const ImageBytesJSONConverter().toJson(imageBytes);
}
