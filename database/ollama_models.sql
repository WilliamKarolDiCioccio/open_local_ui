PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            url TEXT,
            capabilities INTEGER
        );
CREATE TABLE releases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER,
            num_params TEXT,
            size INTEGER,
            FOREIGN KEY(model_id) REFERENCES models(id) ON DELETE CASCADE
        );
CREATE INDEX idx_model_name ON models (name);
CREATE INDEX idx_model_capabilities ON models (capabilities);
COMMIT;
