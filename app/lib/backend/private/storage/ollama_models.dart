import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class OllamaModelsDB {
  static final OllamaModelsDB _instance = OllamaModelsDB._internal();
  Database? _db;

  OllamaModelsDB._internal();

  factory OllamaModelsDB() {
    return _instance;
  }

  // Initialize the database, either in-memory or stored locally
  Future<void> init({bool inMemory = false}) async {
    if (_db != null) return;

    String dbPath = ':memory:';

    if (!kIsWeb && !inMemory) {
      final docDir = await getApplicationSupportDirectory();
      if (!await docDir.exists()) {
        await docDir.create(recursive: true);
      }
      dbPath = p.join(docDir.path, "ollama_models.db");
    }

    _db = sqlite3.open(dbPath);

    _db!.execute('''
        CREATE TABLE IF NOT EXISTS models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            url TEXT,
            vision BOOLEAN,
            tools BOOLEAN,
            embedding BOOLEAN,
            code BOOLEAN
        )
    ''');

    _db!.execute('''
        CREATE TABLE IF NOT EXISTS releases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER,
            num_params TEXT,
            size TEXT,
            FOREIGN KEY(model_id) REFERENCES models(id)
        )
    ''');

    _db!.execute('CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)');
    _db!.execute(
        'CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (vision, tools, embedding, code)');

    debugPrint("Database initialized at $dbPath");
  }

  // Deinitialize (close) the database
  Future<void> deinit() async {
    _db?.dispose();
    _db = null;
  }

  // Get all models from the 'models' table
  List<Map<String, dynamic>> getAllModels() {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select('SELECT * FROM models');

    return result.map((row) => row).toList();
  }

  // Check if a specific model exists in the database by its name
  bool isModelInDatabase(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT * FROM models WHERE name = ?',
      [name],
    );

    return result.isNotEmpty;
  }

  // Check if a model supports a specific feature (vision, tools, embedding, or code)
  bool doesModelSupport(String name, String feature) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT $feature FROM models WHERE name = ?',
      [name],
    );

    if (result.isEmpty) {
      return false;
    }

    final model = result.first;
    return model[feature] == 1;
  }

  // Get the description of a model by its name
  String getModelDescription(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT description FROM models WHERE name = ?',
      [name],
    );

    if (result.isEmpty) {
      return "";
    }

    return result.first['description'] as String;
  }

  // Add a new model to the database
  void addModel(Map<String, dynamic> modelData) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    _db!.execute(
      'INSERT INTO models (name, description, vision, tools, embedding, code) VALUES (?, ?, ?, ?, ?, ?)',
      [
        modelData['name'],
        modelData['description'],
        modelData['vision'] ?? 0,
        modelData['tools'] ?? 0,
        modelData['embedding'] ?? 0,
        modelData['code'] ?? 0,
      ],
    );
  }

  // Delete a model from the database by its name
  void deleteModel(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    _db!.execute(
      'DELETE FROM models WHERE name = ?',
      [name],
    );
  }
}
