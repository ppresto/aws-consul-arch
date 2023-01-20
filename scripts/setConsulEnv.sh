#!/bin/bash

export CONSUL_HTTP_ADDR=https://usw2.consul.328306de-41b8-43a7-9c38-ca8d89d06b07.aws.hashicorp.cloud
export CONSUL_HTTP_TOKEN="${1}"

# Connect CA is 3 day default in Envoy
# curl -s ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots | jq -r '.Roots[0].RootCert' | openssl x509 -text -noout
