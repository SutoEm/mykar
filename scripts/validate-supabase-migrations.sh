#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/backend/supabase/migrations"
TMP_DIR="$(mktemp -d)"
PORT="${PGPORT:-55432}"
DB_NAME="mykar_migration_validation"

cleanup() {
  if [[ -d "$TMP_DIR/data" ]]; then
    pg_ctl -D "$TMP_DIR/data" -m fast stop >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

if ! command -v initdb >/dev/null 2>&1; then
  echo "initdb is required to validate migrations" >&2
  exit 1
fi

if ! command -v pg_ctl >/dev/null 2>&1; then
  echo "pg_ctl is required to validate migrations" >&2
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required to validate migrations" >&2
  exit 1
fi

initdb -D "$TMP_DIR/data" --no-locale -E UTF8 >/dev/null
pg_ctl -D "$TMP_DIR/data" -o "-k $TMP_DIR -p $PORT" -l "$TMP_DIR/postgres.log" start >/dev/null
createdb -h "$TMP_DIR" -p "$PORT" "$DB_NAME"

psql -h "$TMP_DIR" -p "$PORT" -d "$DB_NAME" -v ON_ERROR_STOP=1 <<'SQL'
create extension if not exists pgcrypto;

create schema auth;

create table auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  created_at timestamptz not null default now()
);

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select '00000000-0000-0000-0000-000000000001'::uuid;
$$;

create schema storage;

create table storage.buckets (
  id text primary key,
  name text not null,
  public boolean not null default false,
  file_size_limit bigint,
  allowed_mime_types text[]
);

create table storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text not null references storage.buckets(id),
  name text not null,
  owner uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_accessed_at timestamptz,
  metadata jsonb
);

create role anon;
create role authenticated;
SQL

for migration in "$MIGRATIONS_DIR"/*.sql; do
  echo "Applying $(basename "$migration")"
  psql -h "$TMP_DIR" -p "$PORT" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$migration" >/dev/null
done

echo "Supabase migrations validated successfully"
