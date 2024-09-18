import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.g.dart';

/// Converts [Uint8List] to [Object] and vice versa for JSON serialization.
///
/// This class is used as a JSON converter for the [ChatUserMessageWrapper.imageBytes] property.
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

/// Converts the [ChatMessageSender] object to JSON and vice versa.
///
/// This class is used as a JSON converter for the [ChatMessageWrapper.sender] property.
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

/// NOTE: named with 'Wrapper' suffix to avoid conflict with langchain.dart
///
/// This class is used to encapsulate the properties of a chat message.
///
/// The [ChatMessageWrapper] class is annotated with `@JsonSerializable` to enable JSON serialization and deserialization.
///
/// Properties:
/// - `text`: The text content of the chat message.
/// - `createdAt`: The date and time when the chat message was created.
/// - `uuid`: The unique identifier of the chat message.
/// - `senderName`: The name of the sender of the chat message (optional).
/// - `sender`: The sender of the chat message.
///
/// For metadata and usage statistics see [ChatResult.metadata] in langchain.dart.
/// - `totalDuration`: The total duration of the chat message.
/// - `loadDuration`: The duration it took to load the chat message.
/// - `promptEvalCount`: The number of prompt evaluations performed on the chat message.
/// - `promptEvalDuration`: The duration of prompt evaluations performed on the chat message.
/// - `evalCount`: The number of evaluations performed on the chat message.
/// - `evalDuration`: The duration of evaluations performed on the chat message.
/// - `promptTokens`: The number of prompt tokens in the chat message.
/// - `responseTokens`: The number of response tokens in the chat message.
/// - `totalTokens`: The total number of tokens in the chat message.
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

/// Represents a system message in the chat.
///
/// This class extends the [ChatMessageWrapper] class and sets the sender name and type to 'System'.
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

/// Represents a model message in the chat.
///
/// This class extends the [ChatMessageWrapper] class and sets the sender name and type to 'Model'.
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

/// Represents a user message in the chat.
///
/// This class extends the [ChatMessageWrapper] class and sets the sender name and type to 'User'.
///
/// The [ChatUserMessageWrapper] class also includes an optional [imageBytes] property to store image data for use with multimodal models.
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
