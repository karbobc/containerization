# build tailscale derper
ARG GOLANG_IMAGE
FROM --platform=$BUILDPLATFORM ${GOLANG_IMAGE:-golang:alpine} AS build
ARG DERPER_VERSION
RUN set -x \
    && [ -z $DERPER_VERSION ] || go install tailscale.com/cmd/derper@${DERPER_VERSION} \
    && [ -n $DERPER_VERSION ] || go install tailscale.com/cmd/derper@main \

# derper server
ARG ALPINE_IMAGE
FROM --platform=$TARGETPLATFORM ${ALPINE_IMAGE:-alpine:latest}
LABEL maintainer="Karbob <karbobc@gmail.com>"
ENV TS_DERP_CERTDIR /app/certs
ENV TS_DERP_CERTMODE letsencrypt
ENV TS_DERP_VERIFY_CLIENTS false
ENV TS_DERP_HTTP_PORT -1
ENV TS_DERP_ADDR :443
ENV TS_DERP_STUN_PORT 3478
WORKDIR /app
RUN set -x \
    && mkdir -p ${TS_DERP_CERTDIR}
COPY --from=build /go/bin/derper .
COPY entrypoint.sh /entrypoint.sh

# web ports
EXPOSE 443
# stun
EXPOSE 3478/udp
# certs
VOLUME ${TS_DERP_CERTDIR}

ENTRYPOINT ["/entrypoint.sh"]