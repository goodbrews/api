# Load a BreweryDB API key from config/auth.yml if it exists. Setting the
# BREWERY_DB_API_KEY environment variable on the command line will override this.
auth = YAML.load_file(Rails.root.join('config', 'auth.yml'))
ENV['BREWERY_DB_API_KEY'] ||= auth['brewery_db']['api_key']
