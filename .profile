#!/bin/bash

echo Parsing certs...
(cd /tmp && $HOME/parse_certs.sh)

echo "Capturing cert in cert.pem..."
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > cert.pem

echo "Capturing key in key.pem..."
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' /etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml | sed -e 's/^[ \t]*//' > key.pem
