import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_local_ui/backend/private/models/chat_session.dart';
import 'package:open_local_ui/backend/private/models/chat_message.dart';
import 'package:path_provider/path_provider.dart';

class ChatSessionsDB {
  ChatSessionsDB._internal();

  static final ChatSessionsDB _instance = ChatSessionsDB._internal();

  factory ChatSessionsDB() {
    return _instance;
  }

  /// Initializes the chat sessions database.
  ///
  /// This method calls [Hive.init] to initialize the Hive database with the current Isolate.
  ///
  /// Returns a [Future] that evaluates to `void`.
  Future<void> init() async {
    final dataDir = await getApplicationSupportDirectory();
    Hive.init('${dataDir.path}/sessions');
  }

  /// Deinitializes the chat sessions database.
  ///
  /// This method calls [Hive.close] to close the Hive box and release all resources.
  ///
  /// Returns a [Future] that evaluates to `void`.
  Future<void> deinit() async {
    await Hive.close();
  }

  /// Saves a chat session to the database.
  Future<void> saveSession(ChatSessionWrapperV1 session) async {
    final box = await Hive.openBox<String>('sessions');
    final sessionJson = jsonEncode(session.toJson());
    await box.put(session.uuid, sessionJson);
    await box.close();
  }

  /// Updates a chat session in the database.
  Future<void> updateSession(ChatSessionWrapperV1 session) async {
    final box = await Hive.openBox<String>('sessions');
    final sessionJson = jsonEncode(session.toJson());
    await box.put(session.uuid, sessionJson);
    await box.close();
  }

  Future<void> deleteSession(String uuid) async {
    final box = await Hive.openBox<String>('sessions');
    await box.delete(uuid);
    await box.close();
  }

  /// Loads all chat sessions from the database.
  ///
  /// Sessions are stored in a Hive box named 'sessions' in JSON format.
  /// This method calls [Hive.openBox] to open the box, then iterates over
  /// all keys in the box to retrieve the JSON string for each session.
  /// The JSON string is then decoded into a [ChatSessionWrapperV1] object.
  /// The decoding process of the [ChatSessionWrapperV1] object automatically
  /// manages the decoding of the [ChatMessageWrapperV2] derived objects.
  ///
  /// Returns a list of chat sessions of type [ChatSessionWrapperV1].
  Future<List<ChatSessionWrapperV1>> loadSessions() async {
    final box = await Hive.openBox<String>('sessions');
    final sessions = <ChatSessionWrapperV1>[];

    for (final key in box.keys) {
      final sessionJson = box.get(key);
      if (sessionJson != null) {
        final sessionMap = jsonDecode(sessionJson);
        final session = ChatSessionWrapperV1.fromJson(sessionMap);
        sessions.add(session);
      }
    }

    await box.close();
    return sessions;
  }
}
