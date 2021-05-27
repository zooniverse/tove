require 'faraday'

# Sets a 5 second default timeout for read & write requests
# Faraday is used under the hood by ActiveStorage, and therefore Azure Blob Storage
Faraday.default_connection_options.request.open_timeout = 5
Faraday.default_connection_options.request.timeout = 5
