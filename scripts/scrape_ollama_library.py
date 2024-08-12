import requests
from bs4 import BeautifulSoup
import json
from datetime import datetime  # Import datetime for timestamp


# Function to send a GET request to a URL and return a BeautifulSoup object if successful.
# Returns None if the request fails.
def get_soup(url):
    response = requests.get(url)
    if response.status_code == 200:  # Check if the request was successful
        return BeautifulSoup(response.text, 'html.parser')  # Parse the page content
    else:
        print(f"Failed to retrieve the page: {url}")
        return None


# Function to scrape detailed information about a specific model from its page.
# Extracts the model name and all available releases (excluding "latest").
def scrape_model_details(model_url):
    soup = get_soup(model_url)
    if soup is None:
        return None  # Return None if the page could not be retrieved

    model_details = {}

    # Extract the model name from the page's <h1> tag
    model_name = soup.find('h1', attrs={'class': 'flex items-center sm:text-[28px] text-xl tracking-tight'}, recursive=True)
    if model_name:
        model_details['name'] = model_name.text.strip()  # Clean up and store the model name

    # Check if the model supports vision
    vision_support = soup.find('span', attrs={'class': 'inline-flex items-center rounded-md bg-indigo-50 px-2 py-[2px] text-xs sm:text-[13px] font-medium text-indigo-600'}, string='Vision')
    model_details['vision_support'] = vision_support is not None
    
    # Check if the model supports tools
    tools_support = soup.find('span', attrs={'class': 'inline-flex items-center rounded-md bg-green-50 px-2 py-[2px] text-xs sm:text-[13px] font-medium text-green-600'}, string='Tools')
    model_details['tools_support'] = tools_support is not None
    
    model_releases = []

    # Select all <a> tags within the div with id 'primary-tags'
    release_links = soup.select('#primary-tags a')
    
    for link in release_links:
        # Extract the name of the release from the <span> with a specific class
        release_name = link.find('span', class_='truncate group-hover:underline').text.strip()
        
        # Skip the release if its name is 'latest' to avoid duplicates
        if release_name == 'latest':
            continue
        
        # Extract the size of the release from the <span> with a specific class
        release_size = link.find('span', class_='text-neutral-400 text-xs').text.strip()
        
        # Store the release details in a dictionary and append to the model_releases list
        model_releases.append({
            'num_params': release_name,
            'size': release_size
        })

    # Add the releases to the model_details dictionary if any were found
    if model_releases:
        model_details['releases'] = model_releases

    return model_details


# Function to scrape the main library page and retrieve details for each model.
def scrape_ollama_library():
    base_url = 'https://ollama.com'
    library_url = f'{base_url}/library'
    
    library_soup = get_soup(library_url)
    if library_soup is None:
        return []  # Return an empty list if the library page could not be retrieved

    models = []
    
    # Find all <a> tags that contain links to individual model pages
    model_links = library_soup.find_all('a', href=True)
    for link in model_links:
        model_href = link['href']
        if model_href.startswith('/library/'):  # Check if the link points to a model page
            model_url = f"{base_url}{model_href}"  # Construct the full URL for the model page
            model_details = scrape_model_details(model_url)  # Scrape the model details
            if model_details:
                models.append(model_details)  # Append the model details to the models list
    
    return models


# Main execution block to run the scraper and save the data to a JSON file.
if __name__ == "__main__":
    models_info = scrape_ollama_library()  # Scrape the entire Ollama library
    
    # Prepare data to be saved, including timestamp and model count
    output_data = {
        'timestamp': datetime.now().isoformat(),  # Add the current timestamp
        'num_models': len(models_info),  # Add the number of models scraped
        'models': models_info  # Include the scraped models data
    }
    
    # Save the scraped data to a JSON file with pretty printing (indented format)
    with open('ollama_models.json', 'w') as outfile:
        json.dump(output_data, outfile, indent=4)
    
    # Print a message indicating how many models were scraped and where the data was saved
    print(f"Scraped {len(models_info)} models. Data saved to 'ollama_models.json'.")
