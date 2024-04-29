import 'package:isar/isar.dart';
import 'package:langchain/langchain.dart';

import 'package:open_local_ui/models/chat_message.dart';

part 'chat_session.g.dart';

enum ChatSessionStatus {
  idle,
  generating,
  aborting,
}

@collection
class ChatSessionWrapper {
  final Id id = Isar.autoIncrement;

  String title;
  final String createdAt;
  final String uuid;
  @ignore
  final memory = ConversationBufferMemory(returnMessages: true);
  @ignore
  final List<ChatMessageWrapper> messages = [];
  @enumerated
  ChatSessionStatus status = ChatSessionStatus.idle;

  ChatSessionWrapper(this.title, this.createdAt, this.uuid);
}
