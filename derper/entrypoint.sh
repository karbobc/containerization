#!/usr/bin/env sh

set -eu

# https://tailscale.com/kb/1118/custom-derp-servers
exec /app/derper --hostname="${TS_DERP_HOSTNAME}" \
  --certmode="${TS_DERP_CERTMODE}" \
  --certdir="${TS_DERP_CERTDIR}" \
  --a="${TS_DERP_ADDR}" \
  --stun-port="${TS_DERP_STUN_PORT}" \
  --http-port="${TS_DERP_HTTP_PORT}" \
  --verify-clients="${TS_DERP_VERIFY_CLIENTS}" \
  --stun \
  --derp \
  "$@"