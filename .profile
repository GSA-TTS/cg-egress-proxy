#!/bin/bash

set -e

echo Parsing certs...
(cd /tmp && "$HOME"/parse_certs.sh)

echo "Capturing cert in cert.pem..."
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > cert.pem

echo "Capturing key in key.pem..."
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > key.pem

# The forward_proxy directive references these files.
# So they must exist, even if they will be empty!
touch deny.acl
touch allow.acl

# Ensure there's only one entry per line, and leave no whitespace
PROXY_DENY=$(  echo -n "$PROXY_DENY"  | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )
PROXY_ALLOW=$( echo -n "$PROXY_ALLOW" | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )

# Append to the appropriate files
echo -n "$PROXY_DENY"  >> deny.acl
echo -n "$PROXY_ALLOW" >> allow.acl

# Newline Terminate Non-Empty File If Not Already
# aka NTNEFINA aka ntnefina
# https://stackoverflow.com/a/10082466/17138235
function ntnefina {
    if [ -s "$1" ] && [ "$(tail -c1 "$1"; echo x)" != $'\nx' ]; then
        echo "" >> "$1"
    fi
}

ntnefina deny.acl
ntnefina allow.acl
