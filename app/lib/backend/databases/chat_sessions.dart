import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_local_ui/backend/models/chat_session.dart';
import 'package:path_provider/path_provider.dart';

class ChatSessionsDatabase {
  static Future<void> init() async {
    final dataDir = await getApplicationSupportDirectory();
    Hive.init('${dataDir.path}/sessions');
  }

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
