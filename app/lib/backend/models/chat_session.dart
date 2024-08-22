import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:langchain/langchain.dart';
import 'package:open_local_ui/backend/models/chat_message.dart';

part 'chat_session.g.dart';

/// Converts JSON data to [ChatMessageWrapper] object and vice versa.
///
/// This class determines the type of [ChatMessageWrapper] object to be created based on the 'sender' property.
class ChatMessagesJSONConverter
    implements
        JsonConverter<List<ChatMessageWrapper>, List<Map<String, dynamic>>> {
  const ChatMessagesJSONConverter();

  @override
  List<ChatMessageWrapper> fromJson(List<dynamic> json) {
    return json.map((e) {
      final genericWrapper = ChatMessageWrapper.fromJson(e);

      switch (genericWrapper.sender) {
        case ChatMessageSender.user:
          return ChatUserMessageWrapper.fromJson(e);
        case ChatMessageSender.model:
          return ChatModelMessageWrapper.fromJson(e);
        case ChatMessageSender.system:
          return ChatSystemMessageWrapper.fromJson(e);
      }
    }).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<ChatMessageWrapper> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

enum ChatSessionStatus {
  idle,
  generating,
  aborting,
}

/// NOTE: named with 'Wrapper' suffix to avoid conflict with lancghain.dart
///
/// This class is used to encapsulate the properties of a chat session.
///
/// The [ChatSessionWrapper] class is annotated with `@JsonSerializable` to enable JSON serialization and deserialization.
///
/// Properties:
/// - `title`: The title of the chat session.
/// - `createdAt`: The date and time when the chat session was created.
/// - `uuid`: The unique identifier of the chat session.
/// - `messages`: The list of chat messages associated with the chat session.
/// - `status`: The status of the chat session.
///
/// The [ChatSessionWrapper] class also contains a [memory] property of type [ConversationBufferMemory] for use by langchain.dart.
///
/// NOTE: In the future messages will be stored in an N-Ary tree structure to allow for branching conversations.
@JsonSerializable()
class ChatSessionWrapper {
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
  final List<ChatMessageWrapper> messages;

  @JsonKey(includeToJson: false, includeFromJson: false)
  ChatSessionStatus status = ChatSessionStatus.idle;

  ChatSessionWrapper(
    this.createdAt,
    this.uuid,
    this.messages, {
    this.title = 'Untitled',
  });

  factory ChatSessionWrapper.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionWrapperToJson(this);

  static List<ChatMessageWrapper> _messagesFromJson(List<dynamic> json) =>
      const ChatMessagesJSONConverter().fromJson(json);

  static List<Map<String, dynamic>> _messagesToJson(
          List<ChatMessageWrapper> messages) =>
      const ChatMessagesJSONConverter().toJson(messages);
}
