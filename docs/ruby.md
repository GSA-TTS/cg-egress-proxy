# Using cg-egress-proxy with a Ruby application

By default,[^1] `net/http` proxy support is limited to connecting to `http` proxies, and not `https` proxies. To make proxied connections in Ruby, use [Faraday](https://rubygems.org/gems/faraday) along with one of the following two adapters[^2]:

* [faraday-typhoeus](https://rubygems.org/gems/faraday-typhoeus)
* [faraday-patron](https://rubygems.org/gems/faraday-patron)

Both of those adapters should work out-of-the-box to configure themselves properly from the `http_proxy` and `https_proxy` environment variables and system certificate store.

[^1]: As of September 30, 2024
[^2]: Please update this list if you find more adapters that work. This is not exhaustive.
