create schema jointpay;

set schema 'jointpay';
set search_path to jointpay;

create extension if not exists "uuid-ossp";

create table users (
    id uuid not null default uuid_generate_v1(),
    email varchar(256) not null unique,
    first_name varchar(256),
    last_name varchar(256),
    paypal_account varchar(256),
    primary key (id),
    unique (email)
);

copy users from '/tmp/test-data/users.csv' with (format csv);

create table communities (
    id uuid not null default uuid_generate_v1(),
    name varchar(256) not null,
    last_activity timestamp,
    primary key(id)
);

create index communities_last on communities(last_activity);

create table users_communities (
    user_id uuid not null references users (id),
    community_id uuid not null references communities (id)
);

create index uc_user on users_communities using hash (user_id);
create index uc_community on users_communities using hash (community_id);

create table events (
    id uuid not null default uuid_generate_v1(),
    community_id uuid not null references communities (id),
    name varchar(256) not null,
    description text,
    owner uuid not null,
    target_user uuid references users (id),
    deadline timestamp not null,
    amount money,
    primary key(id)
);

create index events_community on events using hash (community_id);
create index events_owne on events using hash (owner);
create index events_deadline on events (deadline);

create view user_communities as
    select u.id as user_id, c.*
    from users u, communities c, users_communities uc
    where
        u.id = uc.user_id and
        uc.community_id = c.id
;

create view user_events as
    select
        u.id as user_id,
        e.*,
        uc.name community_name
    from
        users u, user_communities uc, events e
    where
        u.id = uc.user_id and
        uc.id = e.community_id and
        u.id <> e.target_user
;
