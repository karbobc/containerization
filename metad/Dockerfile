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

# nginx server
ARG NGINX_IMAGE
FROM --platform=$TARGETPLATFORM ${NGINX_IMAGE:-nginx:alpine}
RUN set -x \
    && rm -f /etc/nginx/conf.d/* \
    && rm -f /usr/share/nginx/html/*
COPY ./conf /etc/nginx/conf.d/
COPY --from=build /app/metad/dist /usr/share/nginx/html/

# web server port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]