# build frontend static files
FROM --platform=$BUILDPLATFORM node:alpine AS build
WORKDIR /app
RUN set -x \
    && apk add --no-cache git \
    && git clone https://github.com/sub-store-org/Sub-Store-Front-End \
    && git clone https://github.com/sub-store-org/Sub-Store \
    && cd /app/Sub-Store-Front-End \
    && npm install -g pnpm \
    && pnpm install \
    && npm run build \
    && cd /app/Sub-Store/backend \
    && pnpm install \
    && pnpm build \
    && pnpm bundle

# node server
FROM --platform=$TARGETPLATFORM alpine:latest
LABEL maintainer="Karbob <karbobc@gmail.com>"

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/app" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    sub-store
USER sub-store
WORKDIR /app

ENV SUB_STORE_FRONTEND_PATH=/app/frontend
ENV SUB_STORE_BACKEND_API_HOST=::
ENV SUB_STORE_FRONTEND_HOST=::
ENV SUB_STORE_FRONTEND_PORT=3001
ENV SUB_STORE_DATA_BASE_PATH=/app/data

RUN set -x \
    && apk add --no-cache nodejs \
    && rm -f /var/cache/apk/*
COPY --from=build /app/Sub-Store-Front-End/dist /app/frontend
COPY --from=build /app/Sub-Store/backend/dist/sub-store.bundle.js /app/

EXPOSE 3001
VOLUME /app/data

CMD ["node", "/app/sub-store.bundle.js"]