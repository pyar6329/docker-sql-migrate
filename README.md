# db-migrate for docker

This is wrap [rubenv/sql-migrate](https://github.com/rubenv/sql-migrate) using Docker

## migrate up

When below files are existed.

```bash
$ tree
.
├── dbconfig.yml
└── migrations
    └── 20191111184655-create-users.sql

$ cat dbconfig.yml
development:
  dialect: postgres
  datasource: host=${DEV_DATABASE_HOST} user=${DEV_DATABASE_USER} password=${DEV_DATABASE_PASSWORD} dbname=${DEV_DATABASE_NAME} port=${DEV_DATABASE_PORT} sslmode=disable
  dir: migrations
  table: migrations
  pool: 5

$ cat migrations/20191111184655-create-users.sql
-- +migrate Up
create table users (
  id bigserial not null primary key,
  email text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index on users (email);
create index on users (created_at desc);
create index on users (updated_at desc);

create table admin_users (
  id bigserial not null primary key,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  user_id bigint not null,
  foreign key (user_id) references users(id)
);

create index on admin_users (created_at desc);
create index on admin_users (updated_at desc);
create unique index on admin_users (user_id);

-- +migrate Down
drop table admin_users;
drop table users;
```

Besides, You run PostgreSQL.

```bash
$ docker run -d \
    --rm \
    --name "example-postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    -e "POSTGRES_DB=example" \
    -p "5432:5432" \
    -e "POSTGRES_INITDB_ARGS=--encoding=UTF-8 --locale=C.UTF-8" \
    postgres:14.11
```

You can run below, and apply migration

```bash
$ [ "$(uname -s)" = "Linux" ] && export LINUX_ARGS="--add-host=host.docker.internal:host-gateway" || export LINUX_ARGS=""

$ docker run \
    --rm \
    -v "$(pwd)/dbconfig.yml:/app/dbconfig.yml" \
    -v "$(pwd)/migrations:/app/migrations" \
    -w "/app" \
    ${LINUX_ARGS} \
    -e "DEV_DATABASE_HOST=host.docker.internal" \
    -e "DEV_DATABASE_USER=postgres" \
    -e "DEV_DATABASE_PASSWORD=postgres" \
    -e "DEV_DATABASE_NAME=example" \
    -e "DEV_DATABASE_PORT=5432" \
    ghcr.io/pyar6329/sql-migrate:1.6.1 up
```

And, check schema;

```bash
$ PGPASSWORD="postgres" psql -h localhost -p 5432 -U postgres -w -d example -c "\d users; \d admin_users;"
```

## migrate down

Run below command, tables are dropped.


```bash
$ [ "$(uname -s)" = "Linux" ] && export LINUX_ARGS="--add-host=host.docker.internal:host-gateway" || export LINUX_ARGS=""

$ docker run \
    --rm \
    -v "$(pwd)/dbconfig.yml:/app/dbconfig.yml" \
    -v "$(pwd)/migrations:/app/migrations" \
    -w "/app" \
    --add-host=host.docker.internal:host-gateway \
    -e "DEV_DATABASE_HOST=host.docker.internal" \
    -e "DEV_DATABASE_USER=postgres" \
    -e "DEV_DATABASE_PASSWORD=postgres" \
    -e "DEV_DATABASE_NAME=example" \
    -e "DEV_DATABASE_PORT=5432" \
    ghcr.io/pyar6329/sql-migrate:1.6.1 down
```

