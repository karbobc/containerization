# build tailscale derper
ARG GOLANG_IMAGE
FROM --platform=$BUILDPLATFORM ${GOLANG_IMAGE:-golang:alpine} AS build
ARG DERPER_VERSION
# https://tailscale.com/kb/1118/custom-derp-servers
RUN set -x \
    && [ -z $DERPER_VERSION ] || go install tailscale.com/cmd/derper@${DERPER_VERSION} \
    && [ -n $DERPER_VERSION ] || go install tailscale.com/cmd/derper@main \

# derper server
ARG ALPINE_IMAGE
FROM --platform=$TARGETPLATFORM ${ALPINE_IMAGE:-alpine:latest}
LABEL maintainer="Karbob <karbobc@gmail.com>"
WORKDIR /app
RUN set -x \
    && apk add --update --no-cache curl
COPY --from=build /go/bin/derper .

# default web ports
EXPOSE 80 443
# default stun port
EXPOSE 3478/udp

ENTRYPOINT ["/app/derper"]