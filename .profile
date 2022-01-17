#!/bin/bash

set -e

echo Parsing certs...
(cd /tmp && "$HOME"/parse_certs.sh)

echo "Capturing cert in cert.pem..."
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > cert.pem

echo "Capturing key in key.pem..."
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > key.pem

# The forward_proxy directive references this file.
# It must exist, even if empty!
touch allow.txt

# Drop any blank lines
PROXY_HOSTS=$(echo "$PROXY_HOSTS" | sed '/^[[:space:]]*$/d')

cat >> allow.txt <<< "$PROXY_HOSTS"

if [ -n "$PROXY_ATTACHED_BUCKETS" ]; then
    n=$(echo "$VCAP_SERVICES" | jq -r '.s3 | length')
    i=0
    while [ $i -lt "$n" ]
    do
        # Add attached buckets to the allow list
        BUCKET=$(echo "$VCAP_SERVICES" | jq -r ".s3[$i].credentials.bucket")
        AWS_ENDPOINT=$(echo "$VCAP_SERVICES" | jq -r ".s3[$i].credentials.endpoint")
        AWS_FIPS_ENDPOINT=$(echo "$VCAP_SERVICES" | jq -r ".s3[$i].credentials.fips_endpoint")
        cat >> allow.txt <<< "${BUCKET}"."${AWS_ENDPOINT}"
        cat >> allow.txt <<< "${BUCKET}"."${AWS_FIPS_ENDPOINT}"
        ((i+=1))
    done
fi
