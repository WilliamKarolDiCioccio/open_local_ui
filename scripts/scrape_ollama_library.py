import requests
from bs4 import BeautifulSoup
import csv
import sqlite3
import re
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

# Thread-safe rate limiting
class RateLimiter:
    def __init__(self, delay=0.5):
        self.delay = delay
        self.lock = Lock()
        self.last_request = 0

    def wait(self):
        with self.lock:
            elapsed = time.time() - self.last_request
            if elapsed < self.delay:
                time.sleep(self.delay - elapsed)
            self.last_request = time.time()


rate_limiter = RateLimiter(delay=0.5)


def convert_to_bytes(size_string: str) -> int:
    units = {
        'B': 1, 'kB': 10**3, 'MB': 10**6, 'GB': 10**9, 'TB': 10**12,
        'KiB': 2**10, 'MiB': 2**20, 'GiB': 2**30, 'TiB': 2**40,
    }
    match = re.match(r"([\d.]+)\s*([a-zA-Z]+)", size_string)
    if not match:
        raise ValueError(f"Invalid size string: {size_string}")
    number, unit = match.groups()
    if unit not in units:
        raise ValueError(f"Unknown unit: {unit}")
    return int(float(number) * units[unit])


def calculate_capabilities(vision=False, tools=False, embedding=False, code=False):
    capabilities = 0
    if vision: capabilities |= 1
    if tools: capabilities |= 2
    if embedding: capabilities |= 4
    if code: capabilities |= 8
    return capabilities


def get_soup(url):
    rate_limiter.wait()
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return BeautifulSoup(response.text, 'html.parser')
        else:
            logging.warning(f"Failed {url}: {response.status_code}")
            return None
    except Exception as e:
        logging.error(f"Error {url}: {e}")
        return None


def scrape_release(model_url, param_size, model_id):
    """Scrape single release - for parallel execution"""
    tag_url = f"{model_url}:{param_size}"
    tag_soup = get_soup(tag_url)

    if not tag_soup:
        return None

    header = tag_soup.find('div', class_='bg-neutral-50')
    if not header:
        return None

    p_tags = header.find_all('p')
    if len(p_tags) >= 1:
        size_text = p_tags[-1].text.strip()
        match = re.search(r'([\d.]+\s*[KMGT]i?B)', size_text)
        if match:
            try:
                byte_size = convert_to_bytes(match.group(1))
                logging.info(f"  ✓ {model_id} {param_size} = {match.group(1)}")
                return {'num_params': param_size, 'size': byte_size}
            except Exception as e:
                logging.error(f"  ✗ Parse failed {param_size}: {e}")
    return None


def scrape_model_releases(model_url, model_id, max_workers=5):
    """Parallel release scraping"""
    soup = get_soup(model_url)
    if not soup:
        return []

    size_badges = soup.find_all('span', {'x-test-size': True})
    param_sizes = [badge.text.strip() for badge in size_badges]

    releases = []
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(scrape_release, model_url, ps, model_id): ps
            for ps in param_sizes
        }

        for future in as_completed(futures):
            result = future.result()
            if result:
                releases.append(result)

    logging.info(f"  Found {len(releases)}/{len(param_sizes)} releases for {model_id}")
    return releases


def scrape_model_details(model_url):
    soup = get_soup(model_url)
    if not soup:
        return None

    model_id = model_url.split('/library/')[-1]
    desc_h2 = soup.find('h2', class_='break-words')

    details = {
        'name': model_id,
        'description': desc_h2.text.strip() if desc_h2 else '',
        'url': model_url,
        'vision': soup.find('span', string='vision') is not None,
        'tools': soup.find('span', string='tools') is not None,
        'embedding': soup.find('span', string='embedding') is not None,
        'code': soup.find('span', string='code') is not None,
    }

    logging.info(f"Scraping: {model_url}")
    details['releases'] = scrape_model_releases(model_url, model_id)

    return details


def scrape_ollama_library(max_workers=10):
    """Parallel model scraping"""
    base_url = 'https://ollama.com'
    library_url = f'{base_url}/library'

    library_soup = get_soup(library_url)
    if not library_soup:
        return {}

    model_links = library_soup.find_all('a', href=True)
    model_urls = [
        f"{base_url}{link['href']}"
        for link in model_links
        if link['href'].startswith('/library/') and link['href'].count('/') == 2
    ]

    models = {}
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(scrape_model_details, url): url for url in model_urls}

        for future in as_completed(futures):
            details = future.result()
            if details and details.get('name'):
                models[details['name']] = details

    return models


def save_data_to_sqlite(models_info):
    conn = sqlite3.connect('ollama_models.db')
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE, description TEXT, url TEXT, capabilities INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS releases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model_id INTEGER, num_params TEXT, size INTEGER,
        FOREIGN KEY(model_id) REFERENCES models(id))''')

    c.execute('CREATE INDEX IF NOT EXISTS idx_model_name ON models (name)')
    c.execute('CREATE INDEX IF NOT EXISTS idx_model_capabilities ON models (capabilities)')

    for model_name, details in models_info.items():
        capabilities_value = calculate_capabilities(
            details['vision'], details['tools'], details['embedding'], details['code'])
        c.execute('INSERT OR IGNORE INTO models (name, description, url, capabilities) VALUES (?, ?, ?, ?)',
                  (model_name, details['description'], details['url'], capabilities_value))
        c.execute('SELECT id FROM models WHERE name = ?', (model_name,))
        model_id = c.fetchone()[0]
        for release in details['releases']:
            c.execute('INSERT INTO releases (model_id, num_params, size) VALUES (?, ?, ?)',
                      (model_id, release['num_params'], release['size']))

    conn.commit()
    conn.close()


def save_data_to_csv(models_info):
    with open('models.csv', mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['name', 'description', 'url', 'capabilities'])
        for model_name, details in models_info.items():
            capabilities_value = calculate_capabilities(
                details['vision'], details['tools'], details['embedding'], details['code'])
            writer.writerow([model_name, details['description'], details['url'], capabilities_value])

    with open('releases.csv', mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(['model_id', 'num_params', 'size'])
            model_id = 1
            for model_name, details in models_info.items():
                for release in details['releases']:
                    writer.writerow([model_id, release['num_params'], release['size']])
                model_id += 1


if __name__ == "__main__":
    models_info = scrape_ollama_library(max_workers=10)
    save_data_to_sqlite(models_info)
    save_data_to_csv(models_info)
    logging.info(f"\nScraped {len(models_info)} models. Saved to DB and CSV.")
