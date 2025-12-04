#!/bin/sh

set -ex

out=$(curl -w "\n\nHTTP_CODE:%{http_code}" -s -X POST -H "X-AccessToken: ${CONTROL_VSHN_NET_TOKEN}" \
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
  }")

grep -q "HTTP_CODE:2" <<EOF || (echo "Failed to register server:\n\n$out" >&2; exit 1)
$out
EOF
