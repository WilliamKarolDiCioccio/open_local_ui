import sqlite3


def create_database_schema():
    # Connect to SQLite database (it will be created if it doesn't exist)
    conn = sqlite3.connect('ollama_models.db')
    c = conn.cursor()

    # Create table for models with a 'url' column
    c.execute('''
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
    ''')

    # Create table for releases
    c.execute('''
        CREATE TABLE IF NOT EXISTS releases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_id INTEGER,
            num_params TEXT,
            size TEXT,
            FOREIGN KEY(model_id) REFERENCES models(id)
        )
    ''')

    # Create indexes on model attributes for fast querying
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)')
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (vision, tools, embedding, code)')

    # Commit the transaction and close the connection
    conn.commit()
    conn.close()


if __name__ == "__main__":
    create_database_schema()

    print("Database schema created. Tables 'models' and 'releases' are now in 'ollama_models.db'.")
