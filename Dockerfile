FROM golang:1.13.4-alpine3.10 AS sql-migrate-build
RUN set -ex && \
  apk add --no-cache --virtual .installer git build-base && \
  go get -v github.com/rubenv/sql-migrate/... && \
  mkdir -p /build && \
  cp -rf /go/bin/sql-migrate /build/sql-migrate

FROM alpine:3.10

WORKDIR /workspace
COPY --from=sql-migrate-build /build/sql-migrate /usr/local/bin/sql-migrate
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN set -ex && \
  chmod +x /usr/local/bin/* && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main postgresql-client && \
