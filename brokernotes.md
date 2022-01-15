# Sketch for egress broker

## Provision

Pushes a caddy app in a broker-owned public-egress space

    cf create-service egress-proxy basic myproxy 

Options might include...

- number of instances
- ...

## Binding

Makes an API call to Caddy to add a forward-proxy config with a generated set of credentials

    cf bind-service myapp egress-proxy -c '{"allow": [ "*.google.com" ] }'

## App responsibilities

- In the .profile, find the value for HTTPS_PROXY in VCAP_SERVICES
  - The value includes the username+password that were generated
- The .profile sets the env var HTTPS_PROXY
- The start-command makes use of HTTPS_PROXY

## Automating usage (a la Monzo)
Get rid of the need for explicit binding. Instead, drive everything from tags on the applications.

- Have an auto-binder app in the space that watches for apps, just like space_drain` app
- The auto-binder inspects every app for `egress` tags. Whenever it finds one it binds the app with a config driven by the tag content.

```
cf push app -t 'egress:*.google.com,egress:usps.gov'
```
