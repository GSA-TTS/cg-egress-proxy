#!/bin/sh

# Despite the temptation to use #!/bin/bash, we want to keep this file as as
# POSIX sh-compatible as possible. This is to facilitate testing the .profile
# under Alpine, which doesn't have /bin/bash, but does have ash (which is itself
# a flavor of busybox).
ENABLE_ASH_BASH_COMPAT=1

# Newline Terminate Non-Empty File If Not Already aka ntnefina
# https://stackoverflow.com/a/10082466/17138235
#
# It's unclear if this works properly under Alpine because it uses ANSI-C
# quoting; that needs more testiing. However, if caddy complains about a blank
# in the file, you know why!
ntnefina() {
    if [ -s "$1" ] && [ "$(tail -c1 "$1"; echo x)" != $'\nx' ]; then
        echo "" >> "$1"
    fi
}

if [ -n "$CONFIG_CONTENT" ]; then
  # new-style deploy, supporting mutliple credentials so not building that string here
  echo "$CONFIG_CONTENT" > Caddyfile
  ./caddy fmt --overwrite
else
  # Ensure there's only one entry per line, and leave no whitespace
  PROXY_DENY=$(  echo -n "$PROXY_DENY"  | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )
  PROXY_ALLOW=$( echo -n "$PROXY_ALLOW" | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )

  # Append to the appropriate files
  echo -n "$PROXY_DENY"  > deny.acl
  echo -n "$PROXY_ALLOW" > allow.acl

  ntnefina deny.acl
  ntnefina allow.acl
fi
