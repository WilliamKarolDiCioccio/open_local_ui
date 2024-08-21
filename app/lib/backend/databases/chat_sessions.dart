import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_local_ui/backend/models/chat_session.dart';
import 'package:path_provider/path_provider.dart';

/// This class provides methods for saving, updating, deleting, and loading chat sessions.
///
/// The chat sessions are stored in a Hive database. This allows to easily save and load chat sessions in the JSON format.
///
/// The Hive Box used to store the chat sessions is named 'sessions'.
/// You can find the database files in the support directory of the app (see the output of [getApplicationSupportDirectory]).
class ChatSessionsDatabase {
  /// Initializes the chat sessions database.
  ///
  /// NOTE: This method must be called before any other methods in this class are called inside the current isolate.
  static Future<void> init() async {
    final dataDir = await getApplicationSupportDirectory();
    Hive.init('${dataDir.path}/sessions');
  }

  /// Deinitializes the chat sessions database.
  static Future<void> deinit() async {
    await Hive.close();
  }

  static Future<void> saveSession(ChatSessionWrapper session) async {
    final box = await Hive.openBox<String>('sessions');

    final sessionJson = jsonEncode(session.toJson());
    await box.put(session.uuid, sessionJson);

    box.close();
  }

  static Future<void> updateSession(ChatSessionWrapper session) async {
    final box = await Hive.openBox<String>('sessions');

    final sessionJson = jsonEncode(session.toJson());
    await box.put(session.uuid, sessionJson);

    box.close();
  }

  static Future<void> deleteSession(String uuid) async {
    final box = await Hive.openBox<String>('sessions');

    await box.delete(uuid);

    box.close();
  }

  static Future<List<ChatSessionWrapper>> loadSessions() async {
    final box = await Hive.openBox<String>('sessions');

    final sessions = <ChatSessionWrapper>[];

    for (final key in box.keys) {
      final sessionJson = box.get(key);
      if (sessionJson != null) {
        final sessionMap = jsonDecode(sessionJson);
        final session = ChatSessionWrapper.fromJson(sessionMap);
        sessions.add(session);
      }
    }

    box.close();

    return sessions;
  }
}
