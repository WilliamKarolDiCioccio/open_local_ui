import requests
from bs4 import BeautifulSoup
import sqlite3
from datetime import datetime


def convert_to_bytes(size_string: str) -> float:
    # Mapping of units to their corresponding byte multipliers
    units = {
        'B': 1,
        'kB': 10**3,        # Kilobyte (base 10)
        'MB': 10**6,        # Megabyte (base 10)
        'GB': 10**9,        # Gigabyte (base 10)
        'TB': 10**12,       # Terabyte (base 10)
        'KiB': 2**10,       # Kibibyte (base 2)
        'MiB': 2**20,       # Mebibyte (base 2)
        'GiB': 2**30,       # Gibibyte (base 2)
        'TiB': 2**40,       # Tebibyte (base 2)
    }

    # Split the string into the numeric part and the unit
    import re
    match = re.match(r"([\d.]+)\s*([a-zA-Z]+)", size_string)
    
    if not match:
        raise ValueError(f"Invalid size string: {size_string}")

    # Extract the numeric part and the unit
    number, unit = match.groups()

    # Convert the numeric part to a float
    number = float(number)

    # Get the byte multiplier for the unit
    if unit not in units:
        raise ValueError(f"Unknown unit: {unit}")
    
    multiplier = units[unit]

    # Return the size in bytes
    return number * multiplier


def calculate_capabilities(vision=False, tools=False, embedding=False, code=False):
    capabilities = 0
    if vision:
        capabilities |= 1  # 1st bit for vision
    if tools:
        capabilities |= 2  # 2nd bit for tools
    if embedding:
        capabilities |= 4  # 3rd bit for embedding
    if code:
        capabilities |= 8  # 4th bit for code
    return capabilities


def get_soup(url):
    response = requests.get(url)
    if response.status_code == 200:  # Check if the request was successful
        return BeautifulSoup(response.text, 'html.parser')  # Parse the page content
    else:
        print(f"Failed to retrieve the page: {url}")
        return None


def scrape_model_details(model_url):
    soup = get_soup(model_url)
    if soup is None:
        return None  # Return None if the page could not be retrieved

    model_details = {}

    # Find model name
    model_name = soup.find('h1', attrs={'class': 'flex items-center sm:text-[28px] text-xl tracking-tight'}, recursive=True)
    if model_name:
        model_details['name'] = model_name.text.strip()
        
    # Find model description
    model_description = soup.find('h2', attrs={'class': 'break-words sm:max-w-md'}, recursive=True)
    if model_description:
        model_details['description'] = model_description.text.strip()
    
    # Store model page url
    model_details['url'] = model_url
    
    print(f"Scraping: {model_details['url']}")

    # Check for various capabilities (vision, tools, embedding, code)
    model_details['vision'] = soup.find('span', string='Vision') is not None
    model_details['tools'] = soup.find('span', string='Tools') is not None
    model_details['embedding'] = soup.find('span', string='Embedding') is not None
    model_details['code'] = soup.find('span', string='Code') is not None

    model_releases = []

    # Select all <a> tags within the div with id 'primary-tags'
    release_links = soup.select('#primary-tags a')
    
    for link in release_links:
        release_name = link.find('span', class_='truncate group-hover:underline').text.strip()
        if release_name == 'latest':
            continue
        
        # Extract the release size string and convert it to bytes
        release_size_string = link.find('span', class_='text-neutral-400 text-xs').text.strip()
        release_size = convert_to_bytes(release_size_string)
        
        model_releases.append({
            'num_params': release_name,
            'size': release_size
        })

    model_details['releases'] = model_releases

    return model_details


def scrape_ollama_library():
    base_url = 'https://ollama.com'
    library_url = f'{base_url}/library'
    
    library_soup = get_soup(library_url)
    if library_soup is None:
        return {}  # Return an empty dictionary if the library page could not be retrieved

    models = {}

    # Find all <a> tags that contain links to individual model pages
    model_links = library_soup.find_all('a', href=True)
    for link in model_links:
        model_href = link['href']
        if model_href.startswith('/library/'):  # Check if the link points to a model page
            model_url = f"{base_url}{model_href}"  # Construct the full URL for the model page
            model_details = scrape_model_details(model_url)  # Scrape the model details
            if model_details:
                model_name = model_details.get('name')
                if model_name:
                    models[model_name] = model_details  # Assign details to the model name key
    
    return models


def save_data_to_sqlite(models_info):
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
            size REAL,
            FOREIGN KEY(model_id) REFERENCES models(id)
        )
    ''')

    # Create an index on the model name for fast querying
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)')
    
    # Create an index on the model capabilities for fast querying
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (capabilities)')

    # Insert data into the tables
    for model_name, details in models_info.items():
        # Calculate the capabilities bitmask
        capabilities_value = calculate_capabilities(
            vision=details['vision'],
            tools=details['tools'],
            embedding=details['embedding'],
            code=details['code']
        )
        
        # Insert the model details into the models table
        c.execute('''
            INSERT OR IGNORE INTO models (name, description, url, capabilities)
            VALUES (?, ?, ?, ?)
        ''', (model_name, details['description'], details['url'], capabilities_value))

        # Get the last inserted model ID (or fetch the existing one)
        c.execute('SELECT id FROM models WHERE name = ?', (model_name,))
        model_id = c.fetchone()[0]

        # Insert the release information for this model
        for release in details['releases']:
            c.execute('''
                INSERT INTO releases (model_id, num_params, size)
                VALUES (?, ?, ?)
            ''', (model_id, release['num_params'], release['size']))

    # Commit the transaction and close the connection
    conn.commit()
    conn.close()
    

if __name__ == "__main__":
    models_info = scrape_ollama_library()

    save_data_to_sqlite(models_info)
    
    print(f"Scraped {len(models_info)} models. Data saved to 'ollama_models.db'.")
