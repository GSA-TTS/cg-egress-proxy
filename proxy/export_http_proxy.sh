#!/bin/sh

# export http(s)_proxy variables. This script should be sourced to be effective


# Despite the temptation to use #!/bin/bash, we want to keep this file as as
# POSIX sh-compatible as possible. This is to facilitate testing the .profile
# under Alpine, which doesn't have /bin/bash, but does have ash (which is itself
# a flavor of busybox).
ENABLE_ASH_BASH_COMPAT=1

# Make it easy to run curl tests on ourselves both locally and deployed
http_proxy_host="localhost"
http_proxy_port="8080"
if [ -n "$VCAP_APPLICATION" ]; then
  https_proxy_scheme="https"
  https_proxy_host=$(echo "$VCAP_APPLICATION" | jq -r '.application_uris[0]')
  https_proxy_port="61443"
else
  https_proxy_scheme="http"
  https_proxy_host="localhost"
  https_proxy_port="8080"
fi

if [ -n "$1" ]; then
  username_var=PROXY_USERNAME_$1
  PROXY_USERNAME=$(eval "echo \$$username_var")
  password_var=PROXY_PASSWORD_$1
  PROXY_PASSWORD=$(eval "echo \$$password_var")
fi

if [ -n "$PROXY_USERNAME" ]; then
  export http_proxy="http://$PROXY_USERNAME:$PROXY_PASSWORD@$http_proxy_host:$http_proxy_port"
  export https_proxy="$https_proxy_scheme://$PROXY_USERNAME:$PROXY_PASSWORD@$https_proxy_host:$https_proxy_port"
else
  echo "Error, no credentials found"
  echo "Usage: 'source ./export_http_proxy.sh CLIENT_SAFE_NAME'"
fi

if [ -n "$http_proxy" ]; then
  echo
  echo "The proxy connection URLs are:"
  echo "http_proxy: $http_proxy"
  echo "https_proxy: $https_proxy"
fi
