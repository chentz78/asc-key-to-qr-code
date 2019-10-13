#!/bin/sh

#####
#
# Author: Kevin Douglas <douglk@gmail.com>
#
# Simple command line script to backup ascii armor gpg keys to paper. You can
# use the following commands to export your keys in ascii armor format:
#
#   gpg --armor --export > pgp-public-keys.asc
#   gpg --armor --export-secret-keys > pgp-private-keys.asc
#   gpg --armor --gen-revoke [your key ID] > pgp-revocation.asc
#
# These can then be used to restore your keys if necessary.
#
# This script will allow you to convert the above ascii armor keys into a
# printable QR code for long-term archival.
#
# This script depends on the following libraries/applications:
#
#   libqrencode (http://fukuchi.org/works/qrencode/)
#
# If you need to backup or restore binary keys, see this link to get started:
#
#   https://gist.github.com/joostrijneveld/59ab61faa21910c8434c#file-gpg2qrcodes-sh
#
#####

# Maximum chuck size to send to the QR encoder. QR version 40 supports
# 2,953 bytes of storage.
max_qr_bytes=2800

# Prefix string for the PNG images that are produced
image_prefix="QR"

# Dependency check
if ! err=$(type qrencode); then
    echo "${err}"
    exit 1
fi

# Argument/usage check
if [ $# -ne 1 ]; then
    echo "usage: $(basename "${0}") <ascii armor key file>"
    exit 1
fi

asc_key=${1}
if [ ! -f "${asc_key}" ]; then
    echo "key file not found: '${asc_key}'"
    exit 1
fi

## Split the key file into usable chunks that the QR encoder can consume
## For each chunk, encode it into a qr image
index=1
while true; do
    s=$(dd bs=${max_qr_bytes} count=1 2>/dev/null)
    if [ ${#s} -gt 0 ]; then
        img="${image_prefix}${index}.png"
        echo "generating ${img}"
        if ! echo -n "${s}" | qrencode -o ${img}; then
            echo "failed to encode image"
            exit 2
        fi
        index=$((index + 1))
    else
        break
    fi
done <"${asc_key}"
