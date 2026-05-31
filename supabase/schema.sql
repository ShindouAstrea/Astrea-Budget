-- =====================================================================
-- Astrea Budget — Esquema de base de datos (Supabase / Postgres)
-- =====================================================================
-- Incluye: tipos enum, tablas, índices, Row Level Security (RLS),
-- trigger de categorías por defecto al registrarse y datos de ejemplo.
--
-- Ejecutar en Supabase: Dashboard → SQL Editor → pegar y "Run".
-- Todas las tablas filtran por auth.uid() = user_id mediante RLS,
-- por lo que cada usuario sólo puede leer/escribir sus propias filas.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tipos enumerados
-- ---------------------------------------------------------------------
create type transaction_type as enum ('income', 'expense');
create type service_type     as enum ('fijo', 'esporadico');
create type service_category as enum ('esencial', 'suscripcion'); -- extensible
create type service_frequency as enum ('mensual', 'bimestral', 'anual', 'unico');
create type payment_status   as enum ('pendiente', 'pagado');

-- ---------------------------------------------------------------------
-- 2. Tabla: categories
-- ---------------------------------------------------------------------
create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null,
  type        transaction_type not null,
  icon        text not null default 'category',     -- nombre de ícono Material
  color       text not null default '#2563EB',      -- hex
  is_default  boolean not null default false,        -- creada por el seed
  created_at  timestamptz not null default now()
);

create index categories_user_idx on public.categories (user_id);

-- ---------------------------------------------------------------------
-- 3. Tabla: services
-- ---------------------------------------------------------------------
create table public.services (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users (id) on delete cascade,
  name              text not null,
  type              service_type not null default 'fijo',
  category          service_category not null default 'esencial',
  estimated_amount  numeric(14,2) not null default 0 check (estimated_amount >= 0),
  billing_day       smallint check (billing_day between 1 and 31), -- día del mes (fijos)
  frequency         service_frequency not null default 'mensual',
  active            boolean not null default true,
  created_at        timestamptz not null default now()
);

create index services_user_idx on public.services (user_id);

-- ---------------------------------------------------------------------
-- 4. Tabla: transactions
-- ---------------------------------------------------------------------
create table public.transactions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  type         transaction_type not null,
  amount       numeric(14,2) not null check (amount > 0),
  date         date not null default current_date,
  description  text,
  category_id  uuid references public.categories (id) on delete set null,
  service_id   uuid references public.services (id) on delete set null, -- enlaza pago a servicio
  created_at   timestamptz not null default now()
);

create index transactions_user_date_idx on public.transactions (user_id, date desc);
create index transactions_category_idx  on public.transactions (category_id);

-- ---------------------------------------------------------------------
-- 5. Tabla: service_payments (lo que vence cada mes)
-- ---------------------------------------------------------------------
create table public.service_payments (
  id              uuid primary key default gen_random_uuid(),
  service_id      uuid not null references public.services (id) on delete cascade,
  user_id         uuid not null references auth.users (id) on delete cascade,
  due_date        date not null,
  amount          numeric(14,2) not null check (amount >= 0),
  status          payment_status not null default 'pendiente',
  paid_date       date,
  transaction_id  uuid references public.transactions (id) on delete set null,
  created_at      timestamptz not null default now(),
  -- Evita duplicar la instancia de pago de un servicio para la misma fecha.
  unique (service_id, due_date)
);

create index service_payments_user_due_idx on public.service_payments (user_id, due_date);
create index service_payments_service_idx  on public.service_payments (service_id);

-- =====================================================================
-- 6. Row Level Security
-- =====================================================================
alter table public.categories       enable row level security;
alter table public.services         enable row level security;
alter table public.transactions     enable row level security;
alter table public.service_payments enable row level security;

-- Privilegios de tabla para el rol de usuarios autenticados. RLS filtra QUÉ
-- filas; estos GRANT otorgan el permiso BASE sobre la tabla (sin ellos, todas
-- las consultas fallan con "permission denied for table ...", error 42501).
grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.categories,
  public.services,
  public.transactions,
  public.service_payments
to authenticated;

-- categories
create policy "categories_select" on public.categories for select using (auth.uid() = user_id);
create policy "categories_insert" on public.categories for insert with check (auth.uid() = user_id);
create policy "categories_update" on public.categories for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "categories_delete" on public.categories for delete using (auth.uid() = user_id);

-- services
create policy "services_select" on public.services for select using (auth.uid() = user_id);
create policy "services_insert" on public.services for insert with check (auth.uid() = user_id);
create policy "services_update" on public.services for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "services_delete" on public.services for delete using (auth.uid() = user_id);

-- transactions
create policy "transactions_select" on public.transactions for select using (auth.uid() = user_id);
create policy "transactions_insert" on public.transactions for insert with check (auth.uid() = user_id);
create policy "transactions_update" on public.transactions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "transactions_delete" on public.transactions for delete using (auth.uid() = user_id);

-- service_payments
create policy "service_payments_select" on public.service_payments for select using (auth.uid() = user_id);
create policy "service_payments_insert" on public.service_payments for insert with check (auth.uid() = user_id);
create policy "service_payments_update" on public.service_payments for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "service_payments_delete" on public.service_payments for delete using (auth.uid() = user_id);

-- =====================================================================
-- 7. Trigger: categorías por defecto al crear la cuenta
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.categories (user_id, name, type, icon, color, is_default) values
    (new.id, 'Sueldo',      'income',  'payments',        '#16A34A', true),
    (new.id, 'Otros ingresos','income','savings',         '#0EA5E9', true),
    (new.id, 'Vivienda',    'expense', 'home',            '#2563EB', true),
    (new.id, 'Comida',      'expense', 'restaurant',      '#F97316', true),
    (new.id, 'Transporte',  'expense', 'directions_bus',  '#8B5CF6', true),
    (new.id, 'Servicios',   'expense', 'bolt',            '#EAB308', true),
    (new.id, 'Salud',       'expense', 'favorite',        '#EF4444', true),
    (new.id, 'Ocio',        'expense', 'sports_esports',  '#EC4899', true),
    (new.id, 'Suscripciones','expense','subscriptions',   '#14B8A6', true),
    (new.id, 'Otros gastos','expense', 'more_horiz',      '#64748B', true);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- 8. (FASE POSTERIOR — NO IMPLEMENTAR AHORA)
-- ---------------------------------------------------------------------
-- Metas de ahorro: dejar previsto el modelo sin implementarlo todavía.
-- create table public.savings_goals (
--   id uuid primary key default gen_random_uuid(),
--   user_id uuid not null references auth.users(id) on delete cascade,
--   name text not null, target_amount numeric(14,2), current_amount numeric(14,2),
--   due_date date, created_at timestamptz default now()
-- );
-- Notificaciones push: la columna service_payments.due_date ya permite
-- calcular recordatorios; la programación se hará en una fase posterior.
-- =====================================================================
