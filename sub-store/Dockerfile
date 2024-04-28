# build frontend static files
ARG NODE_IMAGE
FROM --platform=$BUILDPLATFORM ${NODE_IMAGE:-node:alpine} AS build
ARG SUB_STORE_FRONTEND_VERSION
ARG SUB_STORE_BACKEND_VERSION
WORKDIR /app
RUN set -x \
    && apk add --update --no-cache git \
    && git clone https://github.com/sub-store-org/Sub-Store-Front-End.git \
    && git clone https://github.com/sub-store-org/Sub-Store.git \
    && cd /app/Sub-Store-Front-End \
    && [ -z $SUB_STORE_FRONTEND_VERSION ] || git checkout -q $SUB_STORE_FRONTEND_VERSION \
    && sed -i 's|\(apis.*\)\(url\)\(;\)|\1\2.startsWith("http") ? \2 : `https://\${window.location.host}\${\2}`\3|' \
        src/hooks/useHostAPI.ts \
    && sed -i 's|\(apis.*push.*\)\(url\)|\1\2: \2.startsWith("http") ? \2 : `https://\${window.location.host}\${\2}`|' \
        src/hooks/useHostAPI.ts \
    && npm install -g pnpm \
    && pnpm install \
    && npm run build \
    && cd /app/Sub-Store/backend \
    && [ -z $SUB_STORE_BACKEND_VERSION ] || git checkout $SUB_STORE_BACKEND_VERSION \
    && pnpm install \
    && pnpm build \
    && pnpm bundle

# node server
ARG ALPINE_IMAGE
FROM --platform=$TARGETPLATFORM ${ALPINE_IMAGE:-alpine:latest}

LABEL maintainer="Karbob <karbobc@gmail.com>"

WORKDIR /app
RUN set -x \
    && apk update \
    && apk add --update --no-cache \
        nodejs

ENV SUB_STORE_FRONTEND_PATH=/app/frontend
ENV SUB_STORE_FRONTEND_HOST=::
ENV SUB_STORE_FRONTEND_PORT=8080
ENV SUB_STORE_BACKEND_API_HOST=::
ENV SUB_STORE_BACKEND_API_PORT=3000
ENV SUB_STORE_BACKEND_CRON="0 * * * *"
ENV SUB_STORE_DATA_BASE_PATH=/app/data

COPY --from=build /app/Sub-Store-Front-End/dist ${SUB_STORE_FRONTEND_PATH}
COPY --from=build /app/Sub-Store/backend/dist/sub-store.bundle.js .
COPY entrypoint.sh /entrypoint.sh

EXPOSE 3000 8080
VOLUME ${SUB_STORE_DATA_BASE_PATH}

ENTRYPOINT ["/entrypoint.sh"]