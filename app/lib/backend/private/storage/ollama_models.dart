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
            capabilities INTEGER
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

    _db!.execute(
      'CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)',
    );

    _db!.execute(
      'CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (capabilities)',
    );

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

  // Get models filtered by name and/or capabilities
  List<Map<String, dynamic>> getModelsFiltered({
    String? name,
    List<String>? capabilities,
    double? minSize,
    double? maxSize,
  }) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    // Start query with a join between models and releases
    String query = '''
    SELECT m.* 
    FROM models m
    JOIN releases r ON m.id = r.model_id
    WHERE 1=1
  ''';

    final List<Object?> queryParams = [];

    // Filter by model name
    if (name != null && name.isNotEmpty) {
      query += ' AND m.name LIKE ?';
      queryParams.add('%$name%');
    }

    // Filter by capabilities
    if (capabilities != null && capabilities.isNotEmpty) {
      int capabilitiesMask = 0;

      const int visionMask = 1 << 0;
      const int toolsMask = 1 << 1;
      const int embeddingMask = 1 << 2;
      const int codeMask = 1 << 3;

      for (String capability in capabilities) {
        if (capability == 'vision') {
          capabilitiesMask |= visionMask;
        } else if (capability == 'tools') {
          capabilitiesMask |= toolsMask;
        } else if (capability == 'embedding') {
          capabilitiesMask |= embeddingMask;
        } else if (capability == 'code') {
          capabilitiesMask |= codeMask;
        }
      }

      query += ' AND (m.capabilities & ?) = ?';
      queryParams.add(capabilitiesMask);
      queryParams.add(capabilitiesMask);
    }

    // Filter by minSize and maxSize of the release
    if (minSize != null) {
      query += ' AND r.size >= ?';
      queryParams.add(minSize);
    }

    if (maxSize != null) {
      query += ' AND r.size <= ?';
      queryParams.add(maxSize);
    }

    // Execute the query and return the result
    final result = _db!.select(query, queryParams);

    return result.map((row) => row).toList();
  }

  // Get model releases by model name
  List<Map<String, dynamic>> getModelReleases(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT * FROM releases WHERE model_id = (SELECT id FROM models WHERE name = ?)',
      [name],
    );

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

  // Get the capabilities of a model by its name
  List<String> getModelCapabilities(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT capabilities FROM models WHERE name = ?',
      [name],
    );

    if (result.isEmpty) {
      return [];
    }

    final model = result.first;
    final int capabilities = model['capabilities'];
    final List<String> availableCapabilities = [];

    const int visionMask = 1 << 0;
    const int toolsMask = 1 << 1;
    const int embeddingMask = 1 << 2;
    const int codeMask = 1 << 3;

    if ((capabilities & visionMask) != 0) {
      availableCapabilities.add('vision');
    }
    if ((capabilities & toolsMask) != 0) {
      availableCapabilities.add('tools');
    }
    if ((capabilities & embeddingMask) != 0) {
      availableCapabilities.add('embedding');
    }
    if ((capabilities & codeMask) != 0) {
      availableCapabilities.add('code');
    }

    return availableCapabilities;
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
