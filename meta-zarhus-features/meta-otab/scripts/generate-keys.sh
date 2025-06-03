#!/bin/bash
#
# SPDX-FileCopyrightText: 2023 3mdeb Sp. z o. o. <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

function printHelp {
    cat <<EOF
Usage: generate-keys.sh [options]

    Options:
        TYPE       - type of keys to generate. Select one of these: sig, enc,
                     all
        PASSPHRASE - passphrase use to create keys for signing and encrypting the
                     image

    Example:
        ./generate-keys.sh enc <PASSPHRASE>
        ./generate-keys.sh sig <PASSPHRASE>
        ./generate-keys.sh all <PASSPHRASE>
EOF
}

function create_encryption_key {
    # Create a key via openssl which is part of the OpenSSL project:
    local _passphrase="$1"

    openssl enc -aes-256-cbc -k ${_passphrase} -P -md sha1 -pbkdf2 > enc.key
    SALT=$(grep salt enc.key | cut -d "=" -f2)
    KEY=$(grep key enc.key | cut -d "=" -f2)
    IV=$(grep iv enc.key | cut -d "=" -f2)

    cat <<EOF

Generated encryption keys:

SWUPDATE_ENC_SALT = "${SALT}"
SWUPDATE_ENC_KEY = "${KEY}"
SWUPDATE_ENC_IV = "${IV}"

Add them to distro configuration file of 'meta-customer-layer'.
EOF
}

function create_signed_key_cert {
    # Create password file
    local _passphrase="$1"
    echo "${_passphrase}" > sign_pass.txt

    # Generating self-signed certificates
    openssl req -x509 -newkey rsa:4096 -passin file:sign_pass.txt -nodes \
    -keyout sig.key.pem -out sig.cert.pem -subj "/O=SWUpdate /CN=target"

    cat <<EOF
Generated files (add them to 'recipes-otab/otab-keys/otab-keys-sig' in \
'meta-customer-layer'):
    $(pwd)/sig.key.pem
    $(pwd)/sig.cert.pem

EOF
}

if [ $# -ne 2 ]; then
    echo "Wrong amount of arguments"
    printHelp
    exit
fi

if [[ "$1" == "help" ]]; then
    printHelp
fi

TYPE="$1"
PASSPHRASE="$2"

case "$TYPE" in
    "sig")
        create_signed_key_cert $PASSPHRASE
        ;;
    "enc")
        create_encryption_key $PASSPHRASE
        ;;
    "all")
        create_signed_key_cert $PASSPHRASE
        create_encryption_key $PASSPHRASE
        ;;
    *) printHelp
esac

# Clear unused files
rm sign_pass.txt
