#!/usr/bin/env sh

if [ -z "${TS_DERP_HOSTNAME}" ]; then
    echo "'TS_DERP_HOSTNAME' environment variable must be set!!!"
    exit 1
fi

# https://tailscale.com/kb/1118/custom-derp-servers
exec /app/derper -hostname "${TS_DERP_HOSTNAME}" \
  -certdir "${TS_DERP_CERTDIR}" \
  -certmode "${TS_DERP_CERTMODE}" \
  -verify-clients \
  -derp \
  -stun \
  "$@"