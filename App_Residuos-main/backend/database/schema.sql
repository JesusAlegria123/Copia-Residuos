-- =========================================================
-- Esquema de autenticación segura - App Residuos UNSAAC
-- Ejecutar en Supabase Dashboard -> SQL Editor -> Run
-- =========================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------
-- Tabla: users
-- ---------------------------------------------------------
create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    email varchar(255) unique not null,
    password_hash varchar(255) not null,
    nombre varchar(100) not null,
    rol varchar(50) not null default 'Usuario',
    activo boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    ultimo_login timestamptz
);

create index if not exists idx_users_email on users (email);

-- ---------------------------------------------------------
-- Tabla: refresh_tokens
-- ---------------------------------------------------------
create table if not exists refresh_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users (id) on delete cascade,
    token_hash varchar(255) not null,
    expires_at timestamptz not null,
    created_at timestamptz not null default now(),
    revoked boolean not null default false
);

create index if not exists idx_refresh_tokens_user_id on refresh_tokens (user_id);
create index if not exists idx_refresh_tokens_token_hash on refresh_tokens (token_hash);

-- ---------------------------------------------------------
-- Tabla: login_audit
-- ---------------------------------------------------------
create table if not exists login_audit (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users (id) on delete set null,
    email varchar(255),
    ip_address varchar(64),
    user_agent text,
    success boolean not null,
    error_message varchar(255),
    created_at timestamptz not null default now()
);

create index if not exists idx_login_audit_user_id on login_audit (user_id);

-- ---------------------------------------------------------
-- Trigger para updated_at automático en users
-- ---------------------------------------------------------
create or replace function set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_users_updated_at on users;
create trigger trg_users_updated_at
    before update on users
    for each row
    execute function set_updated_at();

-- ---------------------------------------------------------
-- Row Level Security
-- Nota: el backend se conecta con la Service Role Key, que
-- ignora RLS por diseño. Estas políticas protegen el acceso
-- si en algún momento el cliente (Flutter) consulta con la
-- clave pública (anon key) directamente.
-- ---------------------------------------------------------
alter table users enable row level security;
alter table refresh_tokens enable row level security;
alter table login_audit enable row level security;

drop policy if exists "Usuarios ven solo su perfil" on users;
create policy "Usuarios ven solo su perfil" on users
    for select using (auth.uid()::text = id::text);

drop policy if exists "Usuarios actualizan su perfil" on users;
create policy "Usuarios actualizan su perfil" on users
    for update using (auth.uid()::text = id::text);

drop policy if exists "Sin acceso directo a refresh_tokens" on refresh_tokens;
create policy "Sin acceso directo a refresh_tokens" on refresh_tokens
    for all using (false);

drop policy if exists "Sin acceso directo a login_audit" on login_audit;
create policy "Sin acceso directo a login_audit" on login_audit
    for all using (false);
