import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:langchain/langchain.dart';
import 'package:open_local_ui/backend/private/models/chat_message.dart';

part 'chat_session.g.dart';

/// Converts JSON data to [ChatMessageWrapperV1] object and vice versa.
///
/// This class determines the type of [ChatMessageWrapperV1] object to be created based on the 'sender' property.
@visibleForTesting
class ChatMessagesJSONConverter
    implements
        JsonConverter<List<ChatMessageWrapperV1>, List<Map<String, dynamic>>> {
  const ChatMessagesJSONConverter();

  @override
  List<ChatMessageWrapperV1> fromJson(List<dynamic> json) {
    return json.map((e) {
      final genericWrapper = ChatMessageWrapperV1.fromJson(e);

      switch (genericWrapper.sender) {
        case ChatMessageSender.user:
          return ChatUserMessageWrapperV1.fromJson(e);
        case ChatMessageSender.model:
          return ChatModelMessageWrapperV1.fromJson(e);
        case ChatMessageSender.system:
          return ChatSystemMessageWrapperV1.fromJson(e);
      }
    }).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<ChatMessageWrapperV1> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

enum ChatSessionStatus {
  idle,
  generating,
  aborting,
}

/// The classes with the V1 suffix are used to represent the version of the chat session wrapper format
/// that is currently in use.

/// NOTE: named with 'Wrapper' suffix to avoid conflict with lancghain.dart
///
/// This class is used to encapsulate the properties of a chat session.
///
/// The [ChatSessionWrapperV1] class is annotated with `@JsonSerializable` to enable JSON serialization and deserialization.
///
/// Properties:
/// - `title`: The title of the chat session.
/// - `createdAt`: The date and time when the chat session was created.
/// - `uuid`: The unique identifier of the chat session.
/// - `messages`: The list of chat messages associated with the chat session.
/// - `status`: The status of the chat session.
///
/// The [ChatSessionWrapperV1] class also contains a [memory] property of type [ConversationBufferMemory] for use by langchain.dart.
///
/// NOTE: In the future messages will be stored in an N-Ary tree structure to allow for branching conversations.
@JsonSerializable()
class ChatSessionWrapperV1 {
  String title;
  final DateTime createdAt;
  final String uuid;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final memory = ConversationBufferMemory(returnMessages: true);

  @JsonKey(
    includeToJson: true,
    includeFromJson: true,
    fromJson: _messagesFromJson,
    toJson: _messagesToJson,
  )
  final List<ChatMessageWrapperV1> messages;

  @JsonKey(includeToJson: false, includeFromJson: false)
  ChatSessionStatus status = ChatSessionStatus.idle;

  ChatSessionWrapperV1(
    this.createdAt,
    this.uuid,
    this.messages, {
    this.title = 'Untitled',
  });

  factory ChatSessionWrapperV1.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionWrapperV1FromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionWrapperV1ToJson(this);

  static List<ChatMessageWrapperV1> _messagesFromJson(List<dynamic> json) =>
      const ChatMessagesJSONConverter().fromJson(json);

  static List<Map<String, dynamic>> _messagesToJson(
    List<ChatMessageWrapperV1> messages,
  ) =>
      const ChatMessagesJSONConverter().toJson(messages);
}
