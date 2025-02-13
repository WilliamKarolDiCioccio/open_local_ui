PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE releases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER,
            num_params TEXT,
            size INTEGER,
            FOREIGN KEY(model_id) REFERENCES models(id) ON DELETE CASCADE
        );
COMMIT;
