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
