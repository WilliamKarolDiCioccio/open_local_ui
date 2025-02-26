PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
CREATE TABLE models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            url TEXT,
            capabilities INTEGER
        );
CREATE INDEX idx_model_name ON models (name);
CREATE INDEX idx_model_capabilities ON models (capabilities);
COMMIT;
