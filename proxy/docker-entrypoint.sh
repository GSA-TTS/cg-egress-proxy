#!/bin/sh

# This entrypoint will facilitate a local Docker run of cg-egress-proxy coming as close as possible
# to what happens on cloud.gov with the binary_buildpack

# source .profile to set up allow.acl and deny.acl
. .profile

exec "$@"
