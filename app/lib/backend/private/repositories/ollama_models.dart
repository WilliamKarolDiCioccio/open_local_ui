import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:open_local_ui/core/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModelReleaseDBEntry {
  final int id;
  final String numParams;
  final int size;

  ModelReleaseDBEntry({
    required this.id,
    required this.numParams,
    required this.size,
  });

  factory ModelReleaseDBEntry.fromMap(Map<String, dynamic> map) {
    return ModelReleaseDBEntry(
      id: map['release_id'] as int,
      numParams: map['num_params'] as String,
      size: map['size'] as int,
    );
  }

  @override
  String toString() => 'Release(id: $id, numParams: $numParams, size: $size)';
}

class ModelDBEntry {
  final int id;
  final String name;
  final String description;
  final String url;
  final int capabilities;
  final List<ModelReleaseDBEntry> releases;

  ModelDBEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.capabilities,
    required this.releases,
  });

  factory ModelDBEntry.fromMap(
    Map<String, dynamic> map,
    List<ModelReleaseDBEntry> releases,
  ) {
    return ModelDBEntry(
      id: map['model_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      url: map['url'] as String,
      capabilities: map['capabilities'] as int,
      releases: releases,
    );
  }

  @override
  String toString() => 'Model(id: $id, name: $name, releases: $releases)';
}

class OllamaModelsDB {
  static final OllamaModelsDB _instance = OllamaModelsDB._internal();
  Database? _db;

  OllamaModelsDB._internal();

  factory OllamaModelsDB() {
    return _instance;
  }

  // Initialize the database and fetch the online database for updates
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
            size INTEGER,
            FOREIGN KEY(model_id) REFERENCES models(id) ON DELETE CASCADE
        )
    ''');

    _db!.execute(
      'CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)',
    );

    _db!.execute(
      'CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (capabilities)',
    );

    logger.d('Database initialized at $dbPath');

    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getString('last_ollama_model_db_fetch') ?? "";

    if (lastFetch != currentDate || kDebugMode) {
      await _fetchOnlineDatabase();
      logger.d('Database fetched from Supabase');
    } else {
      logger.d('Database skipped fetching from Supabase');
    }
  }

  // Deinitialize the database
  Future<void> deinit() async {
    _db?.dispose();
    _db = null;
  }

  // Fetch the online database and store it locally
  Future<void> _fetchOnlineDatabase() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ollama_model_db_fetch', currentDate);

    final models = await Supabase.instance.client.from('models').select();

    if (models.isEmpty) return;

    final onlineModelIds = <int>{};
    final onlineReleaseIdentifiers = <String>{};

    logger.i('Fetching ${models.length} models from Supabase');

    _db!.execute('BEGIN TRANSACTION;');

    try {
      logger.i('Updating local database with online models');

      for (final model in models) {
        onlineModelIds.add(model['id']);

        final existingModel = _db!.select(
          'SELECT * FROM models WHERE id = ?',
          [model['id']],
        );

        if (existingModel.isNotEmpty) {
          final existingModelData = existingModel.first;

          if (existingModelData['name'] != model['name'] ||
              existingModelData['url'] != model['url'] ||
              existingModelData['capabilities'] != model['capabilities']) {
            _db!.execute(
              'UPDATE models SET name = ?, url = ?, capabilities = ? WHERE id = ?',
              [
                model['name'],
                model['url'],
                model['capabilities'],
                model['id'],
              ],
            );
          }
        } else {
          _db!.execute(
            'INSERT INTO models (id, name, description, url, capabilities) VALUES (?, ?, ?, ?, ?)',
            [
              model['id'],
              model['name'],
              model['description'],
              model['url'],
              model['capabilities'],
            ],
          );
        }

        final releases = await Supabase.instance.client
            .from('releases')
            .select()
            .eq('model_id', model['id'])
            .order('size');

        for (final release in releases) {
          final releaseIdentifier =
              '${model['id']}-${release['num_params']}-${release['size']}';
          onlineReleaseIdentifiers.add(releaseIdentifier);

          final existingRelease = _db!.select(
            'SELECT * FROM releases WHERE model_id = ? AND num_params = ? AND size = ?',
            [
              model['id'],
              release['num_params'],
              release['size'],
            ],
          );

          if (existingRelease.isEmpty) {
            _db!.execute(
              'INSERT INTO releases (model_id, num_params, size) VALUES (?, ?, ?)',
              [
                model['id'],
                release['num_params'],
                release['size'],
              ],
            );
          }
        }
      }

      final localModels = _db!.select('SELECT id FROM models');

      for (final localModel in localModels) {
        if (!onlineModelIds.contains(localModel['id'])) {
          _db!.execute(
            'DELETE FROM models WHERE id = ?',
            [localModel['id']],
          );
        }
      }

      final localReleases = _db!.select(
        'SELECT model_id, num_params, size FROM releases',
      );

      for (final localRelease in localReleases) {
        final releaseIdentifier =
            '${localRelease['model_id']}-${localRelease['num_params']}-${localRelease['size']}';

        if (!onlineReleaseIdentifiers.contains(releaseIdentifier)) {
          _db!.execute(
            'DELETE FROM releases WHERE model_id = ? AND num_params = ? AND size = ?',
            [
              localRelease['model_id'],
              localRelease['num_params'],
              localRelease['size'],
            ],
          );
        }
      }

      _db!.execute('COMMIT;');
    } catch (e) {
      _db!.execute('ROLLBACK;');
    }
  }

  // Get models filtered by name, release size and/or capabilities
  List<ModelDBEntry> getModelsFiltered({
    String? name,
    Set<String>? capabilities,
    int? minSize,
    int? maxSize,
    int? maxResults,
  }) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    // Helper function to calculate capabilities mask
    int? getCapabilitiesMask(Set<String>? capabilities) {
      if (capabilities == null || capabilities.isEmpty) return null;

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

      return capabilitiesMask;
    }

    final List<Object?> queryParams = [];
    final int? capabilitiesMask = getCapabilitiesMask(capabilities);

    // Main query to fetch models with releases
    String query = '''
      SELECT m.id AS model_id, m.name, m.description, m.url, m.capabilities, r.id AS release_id, r.num_params, r.size
      FROM models m
      LEFT JOIN releases r ON m.id = r.model_id
      WHERE 1=1
    ''';

    if (name != null && name.isNotEmpty) {
      query += ' AND m.name LIKE ?';
      queryParams.add('%$name%');
    }

    if (capabilitiesMask != null) {
      query += ' AND (m.capabilities & ?) = ?';
      queryParams.add(capabilitiesMask);
      queryParams.add(capabilitiesMask);
    }

    if (minSize != null) {
      query += ' AND r.size >= ? OR r.size IS NULL';
      queryParams.add(minSize);
    }

    if (maxSize != null) {
      query += ' AND r.size <= ? OR r.size IS NULL';
      queryParams.add(maxSize);
    }

    final result = _db!.select(query, queryParams);

    final Map<int, ModelDBEntry> modelsMap = {};

    for (final row in result) {
      final modelId = row['model_id'] as int;

      if (!modelsMap.containsKey(modelId)) {
        modelsMap[modelId] = ModelDBEntry(
          id: modelId,
          name: row['name'] as String,
          description: row['description'] as String,
          url: row['url'] as String,
          capabilities: row['capabilities'] as int,
          releases: [],
        );
      }

      if (row['release_id'] != null &&
          row['num_params'] != null &&
          row['size'] != null) {
        final release = ModelReleaseDBEntry.fromMap(row);

        modelsMap[modelId]!.releases.add(release);
      }
    }

    if (maxResults != null && maxResults > 0) {
      return modelsMap.values.take(maxResults).toList();
    }

    return modelsMap.values.toList();
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

  // Get model releases by model name
  List<ModelReleaseDBEntry> getModelReleases(String name) {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    final result = _db!.select(
      'SELECT * FROM releases WHERE model_id = (SELECT id FROM models WHERE name = ?)',
      [name],
    );

    return result.map((row) => ModelReleaseDBEntry.fromMap(row)).toList();
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
}
