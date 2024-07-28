# build static files
ARG NODE_IMAGE
FROM --platform=$BUILDPLATFORM ${NODE_IMAGE:-node:alpine} AS build
ARG METAD_VERSION
WORKDIR /app
RUN set -x \
    && apk add --update --no-cache git \
    && git clone https://github.com/MetaCubeX/metacubexd.git metad \
    && cd metad \
    && [ -z $METAD_VERSION ] || git checkout $METAD_VERSION \
    && [ -n $METAD_VERSION ] || git checkout $(git describe --tags --abbrev=0) \
    && corepack enable \
    && corepack prepare pnpm@latest --activate \
    && pnpm install \
    && pnpm build

# caddy server
ARG CADDY_IMAGE
FROM --platform=$TARGETPLATFORM ${CADDY_IMAGE:-caddy:alpine}
COPY --from=build /app/metad/dist/. .
COPY --from=build /app/metad/Caddyfile .

# web server port
EXPOSE 80

CMD ["caddy", "run"]