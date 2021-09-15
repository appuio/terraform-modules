#!/bin/sh

set -eo pipefail

curl -s -X POST -H "X-AccessToken: ${CONTROL_VSHN_NET_TOKEN}" \
  https://control.vshn.net/api/servers/1/appuio/ \
  -d "{
    \"customer\": \"appuio\",
    \"fqdn\": \"${SERVER_FQDN}\",
    \"location\": \"cloudscale\",
    \"region\": \"${SERVER_REGION}\",
    \"environment\": \"AppuioLbaas\",
    \"project\": \"lbaas\",
    \"role\": \"lb\",
    \"stage\": \"${CLUSTER_ID}\"
  }"
