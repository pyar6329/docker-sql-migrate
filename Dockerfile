FROM golang:1.22-alpine3.19 AS build-base

ARG SQL_MIGRATE_VERSION="1.6.1"

RUN set -x && \
  apk add --no-cache \
    git \
    build-base && \
  go install github.com/rubenv/sql-migrate/...@v${SQL_MIGRATE_VERSION} && \
  cp -rf /go/bin/sql-migrate /usr/local/bin/sql-migrate

FROM alpine:3.19

ARG USER_ID=1000
ARG USER_NAME=migration
ARG HOME_DIR="/home/migration"
ARG PROJECT_ROOT="/app"

RUN set -x && \
  addgroup -g ${USER_ID} -S ${USER_NAME} && \
  adduser -u ${USER_ID} -S -D -G ${USER_NAME} -H -h ${HOME_DIR} -s /bin/ash ${USER_NAME} && \
  mkdir -p ${PROJECT_ROOT} && \
  chown -R ${USER_NAME}:${USER_NAME} ${PROJECT_ROOT}

WORKDIR ${PROJECT_ROOT}
USER ${USER_NAME}

COPY --chmod=755 --from=build-base /usr/local/bin/sql-migrate /usr/local/bin/sql-migrate
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main postgresql-client && \
