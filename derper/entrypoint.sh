#!/usr/bin/env sh

set -eu

# https://tailscale.com/kb/1118/custom-derp-servers
exec /app/derper -hostname "${TS_DERP_HOSTNAME}" \
  -certdir "${TS_DERP_CERTDIR}" \
  -certmode "${TS_DERP_CERTMODE}" \
  -verify-clients "${TS_DERP_VERIFY_CLIENTS}" \
  -derp \
  -stun \
  "$@"