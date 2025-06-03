#!/bin/bash
#
# SPDX-FileCopyrightText: 2023 3mdeb Sp. z o. o. <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

# Function to display usage instructions
usage() {
  echo "Usage: $0 <port> <certificate> <key> [<server_directory>] [<volume_directory>] [<docker_image_name>]"
  echo "  -h, --help            Show this help message and exit."
  echo "  <port>                The port number on which the HTTPS server will listen."
  echo "  <certificate>         Path to the SSL certificate file."
  echo "  <key>                 Path to the private key file for the certificate."
  echo "  <server_directory>    [Optional] Path to the directory where server files and configurations will be stored. Default: \$HOME/.bin/https_py_container."
  echo "  <volume_directory>    [Optional] Path to the directory inside the Docker container where files will be served. Default: server_directory/files."
  echo "  <docker_image_name>   [Optional] Name for the Docker image to be created. Default: https_py_container."
}

# Check if the --help flag is provided
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  usage
  exit 0
fi

# Check if the required number of arguments is provided
if [ $# -lt 4 ] || [ $# -gt 6 ]; then
  usage
  exit 1
fi

# Assign the arguments to variables
port="$1"
certificate="$2"
key="$3"
server_directory="${4:-$HOME/.bin/https_py_container}"  # Default to ~/.bin/https_py_container
volume_directory="${5:-$server_directory/files}"     # Default to ${server_directory}/files
docker_image_name="${6:-https_py_container}"            # Use "https_py_container" as the default value

# Create the server directory and volume directory if they don't exist
mkdir -p "$server_directory"
mkdir -p "$volume_directory"

# Resolve the absolute paths for directories
server_directory=$(realpath "$server_directory")
volume_directory=$(realpath "$volume_directory")

# Copy the certificate and key files to the server directory
cp "$certificate" "$server_directory/certificate.crt"
cp "$key" "$server_directory/private_key.key"

certificate=$(realpath "$certificate")
key=$(realpath "$key")

# Check if the certificate and key files exist
if [ ! -f "$certificate" ] || [ ! -f "$key" ]; then
  echo "Certificate or key file not found."
  exit 1
fi

# Create the Python HTTPS server script with file serving
cat > "$server_directory/server.py" <<EOL
import http.server
import ssl
import os
import logging
import signal

# SSL context setup
context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
context.load_cert_chain(certfile='certificate.crt', keyfile='private_key.key')

port = $port
volume_directory = '/app_volume'
server_directory = '/app'

# Enhanced logging setup
log_format = '%(asctime)s - %(levelname)s - %(message)s'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# File Handler for logging
log_file_path = os.path.join(server_directory, "server.log")
file_handler = logging.FileHandler(log_file_path, mode='a')
file_handler.setFormatter(logging.Formatter(log_format))
logger.addHandler(file_handler)

# Stream Handler for stdout logging
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(logging.Formatter(log_format))
logger.addHandler(stream_handler)

def graceful_shutdown(signum, frame):
    logging.info("Received terminate signal, shutting down...")
    httpd.shutdown()  # shuts down the server

# HTTP Request Handler
class FileHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        return os.path.join(volume_directory, os.path.normpath(path.lstrip('/')))

    def log_request(self, code='-', size='-'):
        self.log_message("Request from %s: %s %s %s",
                         self.client_address[0],
                         self.command,
                         self.path,
                         str(code))

    def log_error(self, format, *args):
        self.log_message(format, *args)

    def log_message(self, format, *args):
        logging.info("%s - - [%s] %s",
                     self.client_address[0],
                     self.log_date_time_string(),
                     format % args)

httpd = http.server.HTTPServer(('0.0.0.0', port), FileHandler)
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

signal.signal(signal.SIGTERM, graceful_shutdown)
logging.info(f"HTTPS server running on port {port}...")
httpd.serve_forever()
EOL

# Create a Dockerfile
cat > "$server_directory/Dockerfile" <<EOL
FROM python:3
RUN apt-get update && apt-get install -y tini
COPY server.py /app/
COPY certificate.crt /app/
COPY private_key.key /app/
WORKDIR /app
CMD ["tini", "--", "python", "server.py"]
EOL

touch $server_directory/server.log

# Build the Docker image
docker build -t "$docker_image_name" "$server_directory"

# Create a separate bash file to run the Docker image with the docker_image_name in its filename
run_script="$server_directory/run_${docker_image_name}_image.sh"
cat > "$run_script" <<EOL
#!/bin/bash

docker run -d -p "$port:$port" -v "$server_directory:/app" -v "$volume_directory:/app_volume" "$docker_image_name"
EOL

# Make the new script executable
chmod +x "$run_script"
