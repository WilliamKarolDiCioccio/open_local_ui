import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_local_ui/models/chat_session.dart';

class SessionsDatabase {
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
