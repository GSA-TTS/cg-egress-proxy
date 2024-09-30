# Using cg-egress-proxy with a Python application

## SSL Certificate errors

It has been found that several Environment variables need to be set for various networking libraries to load the SSL certificate used to protect the TLS connection between the application and the proxy. The following variables have been used:

* `REQUESTS_CA_BUNDLE` for the [requests](https://pypi.org/project/requests/) python library.
* `NEW_RELIC_CA_BUNDLE_PATH` for the [New Relic](https://pypi.org/project/newrelic/) SDK.
