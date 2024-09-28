import sqlite3


def create_database_schema():
    # Connect to SQLite database (it will be created if it doesn't exist)
    conn = sqlite3.connect('ollama_models.db')
    c = conn.cursor()

    # Create table for models
    # Even doe using an integer bitmask to store capabilities is a waste of local storage
    # as SQLite INTEGER takes 64-bit while four bools take 8-bits each for a total of 32-bits,
    # it saves space in the cloud storage and makes querying faster that uses PostgreSQL
    c.execute('''
        CREATE TABLE IF NOT EXISTS models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            url TEXT,
            capabilities INTEGER
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

    # Create an index on the model name for fast querying
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)')
    
    # Create an index on the model capabilities for fast querying
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (capabilities)')

    # Commit the transaction and close the connection
    conn.commit()
    conn.close()


if __name__ == "__main__":
    create_database_schema()

    print("Database schema created. Tables 'models' and 'releases' are now in 'ollama_models.db'.")
