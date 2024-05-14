#!/usr/bin/env sh

set -eu

# https://tailscale.com/kb/1118/custom-derp-servers
exec /app/derper -hostname "${TS_DERP_HOSTNAME}" \
  -certdir "${TS_DERP_CERTDIR}" \
  -certmode "${TS_DERP_CERTMODE}" \
  -verify-clients "${TS_DERP_VERIFY_CLIENTS}" \
  -a "${TS_DERP_ADDR}" \
  -http-port "${TS_DERP_HTTP_PORT}" \
  -stun-port "${TS_DERP_STUN_PORT}" \
  -stun \
  -derp \
  "$@"