#!/bin/bash

echo Parsing certs...
(cd /tmp && $HOME/parse_certs.sh)

echo "Capturing cert in cert.pem..."
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > cert.pem

echo "Capturing key in key.pem..."
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > key.pem

if [ -n "$PROXY_ATTACHED_BUCKETS" ]; then
    # Add attached buckets to the allow list
    AWS_ENDPOINT=$(echo $VCAP_SERVICES | jq -r '.s3[0].credentials'.endpoint)
    AWS_FIPS_ENDPOINT=$(echo $VCAP_SERVICES | jq -r '.s3[0].credentials'.fips_endpoint)
    BUCKET=$(echo $VCAP_SERVICES | jq -r '.s3[0].credentials'.bucket)

    cat > allow.s3.txt << EOF
${BUCKET}.${AWS_ENDPOINT}
${BUCKET}.${AWS_FIPS_ENDPOINT}
EOF
fi
