#!/bin/bash
#
# SPDX-FileCopyrightText: 2023 3mdeb Sp. z o. o. <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

# Function to display usage instructions
function show_usage {
    echo "Usage: $0 [output_directory]"
    echo "Generate OpenSSL certificate, self-signed, with SAN values for \
      hostname, 0.0.0.0, and 127.0.0.1."
    echo "If no output_directory is provided, the certificate will be \
      generated in the current working directory."
}

# Function to display an error message and exit
function die {
    echo "Error: $1"
    show_usage
    exit 1
}

# Function to generate the OpenSSL certificate
function generate_certificate {
    local hostname
    hostname="$(hostname)"
    echo "Generating OpenSSL certificate for hostname: $hostname..."
    openssl req -x509 -newkey rsa:4096 \
      -keyout "$1/key.pem" \
      -out "$1/cert.pem" \
      -days 365 \
      -nodes -subj "/CN=$hostname" \
      -addext "subjectAltName = DNS:$hostname, IP:0.0.0.0, IP:127.0.0.1"
}

# Check if the openssl command is installed
which openssl >/dev/null 2>&1 || die "OpenSSL is not installed. \
Please install OpenSSL before running this script."

# Check for help flag
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_usage
    exit 0
fi

output_dir="."

# Check if a directory argument is provided
if [ $# -eq 1 ]; then
    output_dir="$1"
fi

# Check if the output directory exists
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir" || die \
    "Failed to create output directory: $output_dir"
fi

# Generate the OpenSSL certificate
generate_certificate "$output_dir"

echo "OpenSSL certificate and key files have been generated \
  and saved to: $output_dir"
