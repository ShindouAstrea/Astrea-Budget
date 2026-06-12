-- =====================================================================
-- Astrea Budget — Esquema de base de datos (Supabase / Postgres)
-- =====================================================================
-- FASE 0: cuentas múltiples (#8) + presupuesto compartido (#9) + perfiles.
--
-- Modelo de propiedad: los datos pertenecen a un HOUSEHOLD (presupuesto), no a
-- un usuario. El acceso se controla por membresía (household_members). `user_id`
-- en cada fila indica AUTORÍA, no permiso.
--
-- Niveles de escritura (RLS):
--   A. Movimientos  → transactions          : escribe sólo el autor.
--   B. Estructura   → accounts/categories/services : escribe sólo el owner.
--   C. Pagos        → service_payments       : escribe cualquier miembro.
--   Lectura: siempre compartida dentro del household.
--
-- Ejecutar en Supabase: Dashboard → SQL Editor → pegar y "Run".
-- Es idempotente: los DROP del bloque 0 permiten recrear desde cero.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Limpieza (recrear desde cero — sólo seguro con datos de prueba)
-- ---------------------------------------------------------------------
drop trigger if exists on_auth_user_created on auth.users;
drop view if exists public.account_balances;

drop table if exists public.household_invitations cascade;
drop table if exists public.service_payments cascade;
drop table if exists public.transactions     cascade;
drop table if exists public.services          cascade;
drop table if exists public.categories        cascade;
drop table if exists public.accounts          cascade;
drop table if exists public.household_members cascade;
drop table if exists public.households        cascade;
drop table if exists public.profiles          cascade;

drop function if exists public.handle_new_user()                cascade;
drop function if exists public.handle_guest_converted()         cascade;
drop function if exists public.is_household_member(uuid)        cascade;
drop function if exists public.is_household_owner(uuid)         cascade;
drop function if exists public.shares_household_with(uuid)      cascade;
drop function if exists public.enforce_shared_household_limit() cascade;
drop function if exists public.create_household(text)           cascade;
drop function if exists public.accept_invitation(uuid)          cascade;
drop function if exists public.create_transfer(uuid, uuid, uuid, numeric, date, text) cascade;
drop function if exists public.delete_own_guest_account()       cascade;

drop type if exists transaction_type  cascade;
drop type if exists service_type      cascade;
drop type if exists service_category  cascade;
drop type if exists service_frequency cascade;
drop type if exists payment_status    cascade;
drop type if exists household_role     cascade;
drop type if exists account_type       cascade;
drop type if exists invitation_status  cascade;

-- ---------------------------------------------------------------------
-- 1. Tipos enumerados
-- ---------------------------------------------------------------------
create type transaction_type  as enum ('income', 'expense');
create type service_type      as enum ('fijo', 'esporadico');
create type service_category  as enum ('esencial', 'suscripcion'); -- extensible
create type service_frequency as enum ('mensual', 'bimestral', 'anual', 'unico');
create type payment_status    as enum ('pendiente', 'pagado');
create type household_role     as enum ('owner', 'member');
create type account_type       as enum ('efectivo', 'debito', 'credito', 'ahorro');
create type invitation_status  as enum ('pending', 'accepted', 'declined', 'expired');

-- ---------------------------------------------------------------------
-- 2. Perfiles (display name para personalizar la cuenta y el avatar)
-- ---------------------------------------------------------------------
create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  avatar_url   text,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. Households (presupuestos) y membresías
-- ---------------------------------------------------------------------
create table public.households (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  is_personal boolean not null default false, -- el personal no se borra ni abandona
  created_by  uuid not null references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  role         household_role not null default 'member',
  joined_at    timestamptz not null default now(),
  primary key (household_id, user_id)
);
create index household_members_user_idx on public.household_members (user_id);

-- ---------------------------------------------------------------------
-- 4. Cuentas / billeteras (#8)
-- ---------------------------------------------------------------------
create table public.accounts (
  id              uuid primary key default gen_random_uuid(),
  household_id    uuid not null references public.households (id) on delete cascade,
  user_id         uuid not null references auth.users (id) on delete cascade, -- creador
  name            text not null,
  type            account_type not null default 'debito',
  initial_balance numeric(14,2) not null default 0,
  -- Campos de tarjeta de crédito (sólo cuando type = 'credito'):
  credit_limit    numeric(14,2) check (credit_limit >= 0),
  statement_day   smallint check (statement_day between 1 and 28),   -- día de corte
  payment_due_day smallint check (payment_due_day between 1 and 28), -- día de pago
  color           text not null default '#2563EB',
  icon            text not null default 'account_balance_wallet',
  archived        boolean not null default false,
  created_at      timestamptz not null default now(),
  constraint credit_fields_only_for_credit check (
    type = 'credito'
    or (credit_limit is null and statement_day is null and payment_due_day is null)
  )
);
create index accounts_household_idx on public.accounts (household_id);

-- ---------------------------------------------------------------------
-- 5. Categorías
-- ---------------------------------------------------------------------
create table public.categories (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  name         text not null,
  type         transaction_type not null,
  icon         text not null default 'category',
  color        text not null default '#2563EB',
  is_default   boolean not null default false,
  created_at   timestamptz not null default now()
);
create index categories_household_idx on public.categories (household_id);

-- ---------------------------------------------------------------------
-- 6. Servicios (gastos recurrentes / esporádicos)
-- ---------------------------------------------------------------------
create table public.services (
  id               uuid primary key default gen_random_uuid(),
  household_id     uuid not null references public.households (id) on delete cascade,
  user_id          uuid not null references auth.users (id) on delete cascade,
  name             text not null,
  type             service_type not null default 'fijo',
  category         service_category not null default 'esencial',
  estimated_amount numeric(14,2) not null default 0 check (estimated_amount >= 0),
  billing_day      smallint check (billing_day between 1 and 31),
  frequency        service_frequency not null default 'mensual',
  active           boolean not null default true,
  created_at       timestamptz not null default now()
);
create index services_household_idx on public.services (household_id);

-- ---------------------------------------------------------------------
-- 7. Transacciones (movimientos)
-- ---------------------------------------------------------------------
create table public.transactions (
  id                uuid primary key default gen_random_uuid(),
  household_id      uuid not null references public.households (id) on delete cascade,
  user_id           uuid not null references auth.users (id) on delete cascade, -- autor
  account_id        uuid references public.accounts (id) on delete set null,
  type              transaction_type not null,
  amount            numeric(14,2) not null check (amount > 0),
  date              date not null default current_date,
  description       text,
  category_id       uuid references public.categories (id) on delete set null,
  service_id        uuid references public.services (id) on delete set null,
  -- Transferencias (#8): par de filas (expense origen + income destino) con el
  -- mismo grupo. Se excluyen del resumen de ingresos/gastos del dashboard.
  transfer_group_id uuid,
  created_at        timestamptz not null default now()
);
create index transactions_household_date_idx on public.transactions (household_id, date desc);
create index transactions_account_idx        on public.transactions (account_id);
create index transactions_category_idx       on public.transactions (category_id);
create index transactions_transfer_idx       on public.transactions (transfer_group_id);

-- ---------------------------------------------------------------------
-- 8. Pagos de servicios (lo que vence cada mes)
-- ---------------------------------------------------------------------
create table public.service_payments (
  id             uuid primary key default gen_random_uuid(),
  household_id   uuid not null references public.households (id) on delete cascade,
  service_id     uuid not null references public.services (id) on delete cascade,
  user_id        uuid not null references auth.users (id) on delete cascade,
  due_date       date not null,
  amount         numeric(14,2) not null check (amount >= 0),
  status         payment_status not null default 'pendiente',
  paid_date      date,
  transaction_id uuid references public.transactions (id) on delete set null,
  created_at     timestamptz not null default now(),
  unique (service_id, due_date)
);
create index service_payments_household_due_idx on public.service_payments (household_id, due_date);
create index service_payments_service_idx       on public.service_payments (service_id);

-- ---------------------------------------------------------------------
-- 9. Invitaciones a presupuesto compartido (#9)
-- ---------------------------------------------------------------------
create table public.household_invitations (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  email        text not null,
  invited_by   uuid not null references auth.users (id) on delete cascade,
  status       invitation_status not null default 'pending',
  created_at   timestamptz not null default now(),
  expires_at   timestamptz not null default now() + interval '7 days'
);
create index household_invitations_email_idx on public.household_invitations (lower(email));
create index household_invitations_household_idx on public.household_invitations (household_id);

-- =====================================================================
-- 10. Funciones helper (security definer: NO aplican RLS dentro → cortan
--     recursión y centralizan los chequeos de membresía/rol)
-- =====================================================================
create or replace function public.is_household_member(hid uuid)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (
    select 1 from public.household_members
    where household_id = hid and user_id = auth.uid()
  );
$$;

create or replace function public.is_household_owner(hid uuid)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (
    select 1 from public.household_members
    where household_id = hid and user_id = auth.uid() and role = 'owner'
  );
$$;

create or replace function public.shares_household_with(other uuid)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (
    select 1
    from public.household_members a
    join public.household_members b on a.household_id = b.household_id
    where a.user_id = auth.uid() and b.user_id = other
  );
$$;

-- =====================================================================
-- 11. Row Level Security
-- =====================================================================
alter table public.profiles              enable row level security;
alter table public.households            enable row level security;
alter table public.household_members     enable row level security;
alter table public.accounts              enable row level security;
alter table public.categories            enable row level security;
alter table public.services              enable row level security;
alter table public.transactions          enable row level security;
alter table public.service_payments      enable row level security;
alter table public.household_invitations enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.profiles, public.households, public.household_members,
  public.accounts, public.categories, public.services,
  public.transactions, public.service_payments, public.household_invitations
to authenticated;

-- ---- profiles: el propio + co-miembros de household ----
create policy "profiles_select" on public.profiles
  for select using (id = auth.uid() or public.shares_household_with(id));
create policy "profiles_update" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());
-- insert lo hace el trigger handle_new_user (security definer).

-- ---- households: ver los que integro; sólo owner edita; creación vía RPC ----
create policy "households_select" on public.households
  for select using (public.is_household_member(id));
create policy "households_update" on public.households
  for update using (public.is_household_owner(id))
              with check (public.is_household_owner(id));
create policy "households_delete" on public.households
  for delete using (public.is_household_owner(id) and is_personal = false);
-- insert NO permitido directo: usar create_household() (controla límite + owner).

-- ---- household_members: lectura de mis households; salir/expulsar ----
-- inserciones SÓLO vía funciones security definer (create_household / accept_invitation).
create policy "members_select" on public.household_members
  for select using (public.is_household_member(household_id));
create policy "members_delete" on public.household_members
  for delete using (
    user_id = auth.uid()                          -- puedo salirme yo
    or public.is_household_owner(household_id)     -- o el owner me saca
  );

-- ---- Nivel B: accounts / categories / services (escribe sólo el owner) ----
create policy "accounts_select" on public.accounts
  for select using (public.is_household_member(household_id));
create policy "accounts_insert" on public.accounts
  for insert with check (public.is_household_owner(household_id) and user_id = auth.uid());
create policy "accounts_update" on public.accounts
  for update using (public.is_household_owner(household_id))
              with check (public.is_household_owner(household_id));
create policy "accounts_delete" on public.accounts
  for delete using (public.is_household_owner(household_id));

create policy "categories_select" on public.categories
  for select using (public.is_household_member(household_id));
create policy "categories_insert" on public.categories
  for insert with check (public.is_household_owner(household_id) and user_id = auth.uid());
create policy "categories_update" on public.categories
  for update using (public.is_household_owner(household_id))
              with check (public.is_household_owner(household_id));
create policy "categories_delete" on public.categories
  for delete using (public.is_household_owner(household_id));

create policy "services_select" on public.services
  for select using (public.is_household_member(household_id));
create policy "services_insert" on public.services
  for insert with check (public.is_household_owner(household_id) and user_id = auth.uid());
create policy "services_update" on public.services
  for update using (public.is_household_owner(household_id))
              with check (public.is_household_owner(household_id));
create policy "services_delete" on public.services
  for delete using (public.is_household_owner(household_id));

-- ---- Nivel A: transactions (escribe sólo el autor) ----
create policy "transactions_select" on public.transactions
  for select using (public.is_household_member(household_id));
create policy "transactions_insert" on public.transactions
  for insert with check (public.is_household_member(household_id) and user_id = auth.uid());
create policy "transactions_update" on public.transactions
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "transactions_delete" on public.transactions
  for delete using (user_id = auth.uid());

-- ---- Nivel C: service_payments (cualquier miembro genera/paga) ----
create policy "service_payments_select" on public.service_payments
  for select using (public.is_household_member(household_id));
create policy "service_payments_insert" on public.service_payments
  for insert with check (public.is_household_member(household_id));
create policy "service_payments_update" on public.service_payments
  for update using (public.is_household_member(household_id))
              with check (public.is_household_member(household_id));
create policy "service_payments_delete" on public.service_payments
  for delete using (public.is_household_member(household_id));

-- ---- household_invitations: el owner gestiona; el invitado ve las suyas ----
create policy "invitations_select" on public.household_invitations
  for select using (
    public.is_household_owner(household_id)
    or lower(email) = lower(auth.jwt() ->> 'email')
  );
create policy "invitations_insert" on public.household_invitations
  for insert with check (public.is_household_owner(household_id) and invited_by = auth.uid());
create policy "invitations_delete" on public.household_invitations
  for delete using (public.is_household_owner(household_id));
-- aceptar/declinar se hace vía accept_invitation() (security definer).

-- =====================================================================
-- 12. Vista de saldos por cuenta (security_invoker → respeta RLS de accounts)
-- =====================================================================
create view public.account_balances with (security_invoker = true) as
select
  a.id           as account_id,
  a.household_id as household_id,
  a.initial_balance
    + coalesce(sum(case when t.type = 'income'  then t.amount else 0 end), 0)
    - coalesce(sum(case when t.type = 'expense' then t.amount else 0 end), 0)
    as balance
from public.accounts a
left join public.transactions t on t.account_id = a.id
group by a.id;

grant select on public.account_balances to authenticated;

-- =====================================================================
-- 12b. Helper: sembrar defaults de un household (cuenta + categorías).
-- ---------------------------------------------------------------------
-- Reutilizado por el onboarding (handle_new_user), el bootstrap y la creación
-- de presupuestos compartidos (create_household), para que TODO household nazca
-- con su cuenta "Principal" y el set de categorías por defecto.
-- =====================================================================
create or replace function public.seed_household_defaults(hid uuid, uid uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.accounts (household_id, user_id, name, type)
    values (hid, uid, 'Principal', 'debito');

  insert into public.categories (household_id, user_id, name, type, icon, color, is_default) values
    (hid, uid, 'Sueldo',        'income',  'payments',       '#16A34A', true),
    (hid, uid, 'Otros ingresos','income',  'savings',        '#0EA5E9', true),
    (hid, uid, 'Vivienda',      'expense', 'home',           '#2563EB', true),
    (hid, uid, 'Comida',        'expense', 'restaurant',     '#F97316', true),
    (hid, uid, 'Transporte',    'expense', 'directions_bus', '#8B5CF6', true),
    (hid, uid, 'Servicios',     'expense', 'bolt',           '#EAB308', true),
    (hid, uid, 'Salud',         'expense', 'favorite',       '#EF4444', true),
    (hid, uid, 'Ocio',          'expense', 'sports_esports', '#EC4899', true),
    (hid, uid, 'Suscripciones', 'expense', 'subscriptions',  '#14B8A6', true),
    (hid, uid, 'Otros gastos',  'expense', 'more_horiz',     '#64748B', true);
end; $$;

-- =====================================================================
-- 13. Onboarding: al registrarse, crear perfil + household personal +
--     membresía owner + cuenta por defecto + categorías por defecto.
--     Los usuarios anónimos (modo invitado) no tienen email: caen al
--     nombre 'Invitado'.
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  hid uuid;
  v_name text := coalesce(
    nullif(new.raw_user_meta_data ->> 'name', ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'Invitado'
  );
begin
  insert into public.profiles (id, display_name) values (new.id, v_name);

  insert into public.households (name, is_personal, created_by)
    values ('Personal', true, new.id)
    returning id into hid;

  insert into public.household_members (household_id, user_id, role)
    values (hid, new.id, 'owner');

  perform public.seed_household_defaults(hid, new.id);
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- 13b. Conversión de invitado: asociar correo al usuario anónimo
--     (updateUser) es un UPDATE en auth.users, así que handle_new_user
--     no corre y el perfil quedaría como 'Invitado'. Cuando el correo se
--     materializa (inmediato si la confirmación está desactivada, o al
--     confirmar el enlace), se reemplaza por el nombre elegido o el
--     prefijo del correo. No toca perfiles renombrados manualmente.
-- =====================================================================
create or replace function public.handle_guest_converted()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.profiles
     set display_name = coalesce(
           nullif(new.raw_user_meta_data ->> 'name', ''),
           nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
           display_name
         )
   where id = new.id
     and display_name = 'Invitado';
  return new;
end; $$;

create trigger on_auth_user_converted
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email and coalesce(new.email, '') <> '')
  execute function public.handle_guest_converted();

-- =====================================================================
-- 14. RPC: crear household compartido (controla el límite de 3 + owner)
-- =====================================================================
create or replace function public.create_household(p_name text)
returns uuid language plpgsql security definer set search_path = public as $$
declare hid uuid; shared_count int;
begin
  select count(*) into shared_count
    from public.household_members m
    join public.households h on h.id = m.household_id
    where m.user_id = auth.uid() and h.is_personal = false;
  if shared_count >= 3 then
    raise exception 'Alcanzaste el máximo de 3 presupuestos compartidos';
  end if;

  insert into public.households (name, is_personal, created_by)
    values (coalesce(nullif(p_name, ''), 'Compartido'), false, auth.uid())
    returning id into hid;
  insert into public.household_members (household_id, user_id, role)
    values (hid, auth.uid(), 'owner');
  perform public.seed_household_defaults(hid, auth.uid());
  return hid;
end; $$;

-- =====================================================================
-- 15. RPC: aceptar invitación (crea la membresía; respeta el límite de 3)
-- =====================================================================
create or replace function public.accept_invitation(invitation_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare inv public.household_invitations; shared_count int;
begin
  select * into inv from public.household_invitations where id = invitation_id;
  if inv is null or inv.status <> 'pending' or inv.expires_at < now() then
    raise exception 'Invitación inválida o expirada';
  end if;
  if lower(inv.email) <> lower(auth.jwt() ->> 'email') then
    raise exception 'La invitación no es para este usuario';
  end if;

  select count(*) into shared_count
    from public.household_members m
    join public.households h on h.id = m.household_id
    where m.user_id = auth.uid() and h.is_personal = false;
  if shared_count >= 3 then
    raise exception 'Alcanzaste el máximo de 3 presupuestos compartidos';
  end if;

  insert into public.household_members (household_id, user_id, role)
    values (inv.household_id, auth.uid(), 'member')
    on conflict do nothing;
  update public.household_invitations set status = 'accepted' where id = invitation_id;
end; $$;

-- =====================================================================
-- 16. RPC: transferir entre cuentas (par de transacciones atómico)
-- =====================================================================
create or replace function public.create_transfer(
  p_household    uuid,
  p_from_account uuid,
  p_to_account   uuid,
  p_amount       numeric,
  p_date         date,
  p_description  text
) returns uuid language plpgsql security definer set search_path = public as $$
declare grp uuid := gen_random_uuid();
begin
  if not public.is_household_member(p_household) then
    raise exception 'No autorizado';
  end if;
  if p_amount <= 0 then
    raise exception 'El monto debe ser positivo';
  end if;
  insert into public.transactions
    (household_id, user_id, type, amount, date, description, account_id, transfer_group_id)
  values
    (p_household, auth.uid(), 'expense', p_amount, p_date, p_description, p_from_account, grp),
    (p_household, auth.uid(), 'income',  p_amount, p_date, p_description, p_to_account,   grp);
  return grp;
end; $$;

-- =====================================================================
-- 16b. RPC: invitaciones pendientes para MÍ (por email del JWT)
-- ---------------------------------------------------------------------
-- El invitado aún no es miembro del household, así que RLS le impide leer su
-- nombre desde `households`. Este RPC (security definer) devuelve la invitación
-- junto al nombre del household y de quien invita, para mostrarla.
-- =====================================================================
create or replace function public.my_invitations()
returns table (
  id              uuid,
  household_id    uuid,
  household_name  text,
  invited_by_name text,
  created_at      timestamptz,
  expires_at      timestamptz
) language sql security definer set search_path = public stable as $$
  select i.id, i.household_id, h.name, p.display_name, i.created_at, i.expires_at
  from public.household_invitations i
  join public.households h on h.id = i.household_id
  left join public.profiles p on p.id = i.invited_by
  where i.status = 'pending'
    and lower(i.email) = lower(auth.jwt() ->> 'email')
    and i.expires_at > now();
$$;

-- =====================================================================
-- 16c. RPC: eliminar la cuenta de invitado junto con todos sus datos
-- ---------------------------------------------------------------------
-- La sesión anónima de un invitado no es recuperable: si solo cerrara
-- sesión, su usuario y datos quedarían huérfanos para siempre. Este RPC
-- borra el usuario de auth.users y los FK `on delete cascade` arrastran
-- perfil, households, cuentas, transacciones, etc.
-- =====================================================================
create or replace function public.delete_own_guest_account()
returns void language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  if not exists (select 1 from auth.users where id = v_uid and is_anonymous) then
    raise exception 'Solo una cuenta de invitado puede auto-eliminarse';
  end if;
  -- Si el invitado creó un presupuesto compartido donde participan otras
  -- personas, el cascade destruiría datos ajenos: mejor impedirlo.
  if exists (
    select 1
    from public.households h
    join public.household_members m on m.household_id = h.id
    where h.created_by = v_uid and h.is_personal = false and m.user_id <> v_uid
  ) then
    raise exception 'Tienes un presupuesto compartido con otros miembros';
  end if;
  delete from auth.users where id = v_uid;
end; $$;

-- =====================================================================
-- 17. Bootstrap de usuarios ya existentes
-- ---------------------------------------------------------------------
-- El trigger on_auth_user_created sólo corre en el REGISTRO. Las cuentas
-- creadas antes de este esquema no tienen perfil/household/cuenta/categorías.
-- Este bloque las crea para cada usuario existente. Es idempotente: salta a
-- quien ya tenga household personal, así que correr el schema varias veces no
-- duplica datos.
-- =====================================================================
do $$
declare u record; hid uuid; v_name text;
begin
  for u in select * from auth.users loop
    if exists (select 1 from public.households where created_by = u.id and is_personal) then
      continue;
    end if;
    -- Mismo fallback que handle_new_user: los usuarios anónimos (invitados)
    -- no tienen email y sin 'Invitado' el insert violaría el not null.
    v_name := coalesce(
      nullif(u.raw_user_meta_data ->> 'name', ''),
      nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
      'Invitado'
    );

    insert into public.profiles (id, display_name) values (u.id, v_name)
      on conflict (id) do nothing;

    insert into public.households (name, is_personal, created_by)
      values ('Personal', true, u.id) returning id into hid;

    insert into public.household_members (household_id, user_id, role)
      values (hid, u.id, 'owner');

    perform public.seed_household_defaults(hid, u.id);
  end loop;
end $$;

-- =====================================================================
-- 18. Presupuestos por categoría (#1)
-- ---------------------------------------------------------------------
-- Tope mensual de gasto por categoría. Estructura del presupuesto → RLS
-- Nivel B: lo gestiona el owner; todos los miembros lo ven. Un tope por
-- (household, categoría). El gasto del mes se calcula en la app.
-- =====================================================================
drop table if exists public.budgets cascade;

create table public.budgets (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade, -- creador
  category_id  uuid not null references public.categories (id) on delete cascade,
  amount       numeric(14,2) not null check (amount >= 0),
  created_at   timestamptz not null default now(),
  unique (household_id, category_id)
);
create index budgets_household_idx on public.budgets (household_id);

alter table public.budgets enable row level security;
grant select, insert, update, delete on public.budgets to authenticated;

create policy "budgets_select" on public.budgets
  for select using (public.is_household_member(household_id));
create policy "budgets_insert" on public.budgets
  for insert with check (public.is_household_owner(household_id) and user_id = auth.uid());
create policy "budgets_update" on public.budgets
  for update using (public.is_household_owner(household_id))
              with check (public.is_household_owner(household_id));
create policy "budgets_delete" on public.budgets
  for delete using (public.is_household_owner(household_id));

-- =====================================================================
-- 19. Ingresos recurrentes (#7)
-- ---------------------------------------------------------------------
-- Plantilla de ingreso que se auto-registra cada mes (ej. sueldo). La
-- generación corre en la app: cada usuario genera SUS propios ingresos (la
-- transacción resultante lleva su user_id, Nivel A). Por eso escritura = autor;
-- lectura compartida en el household.
-- =====================================================================
drop table if exists public.recurring_incomes cascade;

create table public.recurring_incomes (
  id             uuid primary key default gen_random_uuid(),
  household_id   uuid not null references public.households (id) on delete cascade,
  user_id        uuid not null references auth.users (id) on delete cascade, -- autor
  description    text not null,
  amount         numeric(14,2) not null check (amount > 0),
  category_id    uuid references public.categories (id) on delete set null,
  account_id     uuid references public.accounts (id) on delete set null,
  day_of_month   smallint not null check (day_of_month between 1 and 28),
  active         boolean not null default true,
  last_generated date,  -- fecha de la última ocurrencia generada (idempotencia)
  created_at     timestamptz not null default now()
);
create index recurring_incomes_household_user_idx
  on public.recurring_incomes (household_id, user_id);

alter table public.recurring_incomes enable row level security;
grant select, insert, update, delete on public.recurring_incomes to authenticated;

create policy "recurring_incomes_select" on public.recurring_incomes
  for select using (public.is_household_member(household_id));
create policy "recurring_incomes_insert" on public.recurring_incomes
  for insert with check (public.is_household_member(household_id) and user_id = auth.uid());
create policy "recurring_incomes_update" on public.recurring_incomes
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "recurring_incomes_delete" on public.recurring_incomes
  for delete using (user_id = auth.uid());

-- =====================================================================
-- 20. Metas de ahorro (#3)
-- ---------------------------------------------------------------------
-- Meta con monto objetivo y monto ahorrado. En un household compartido es
-- colaborativa: cualquier miembro la ve, crea y aporta; sólo el creador o el
-- owner la borran. El aporte (positivo/negativo) se aplica atómicamente por RPC.
-- =====================================================================
drop table if exists public.savings_goals cascade;

create table public.savings_goals (
  id             uuid primary key default gen_random_uuid(),
  household_id   uuid not null references public.households (id) on delete cascade,
  user_id        uuid not null references auth.users (id) on delete cascade, -- creador
  name           text not null,
  target_amount  numeric(14,2) not null check (target_amount > 0),
  current_amount numeric(14,2) not null default 0 check (current_amount >= 0),
  target_date    date,
  account_id     uuid references public.accounts (id) on delete set null, -- opcional
  icon           text not null default 'savings',
  color          text not null default '#16A34A',
  created_at     timestamptz not null default now()
);
create index savings_goals_household_idx on public.savings_goals (household_id);

alter table public.savings_goals enable row level security;
grant select, insert, update, delete on public.savings_goals to authenticated;

create policy "savings_goals_select" on public.savings_goals
  for select using (public.is_household_member(household_id));
create policy "savings_goals_insert" on public.savings_goals
  for insert with check (public.is_household_member(household_id) and user_id = auth.uid());
create policy "savings_goals_update" on public.savings_goals
  for update using (public.is_household_member(household_id))
              with check (public.is_household_member(household_id));
create policy "savings_goals_delete" on public.savings_goals
  for delete using (user_id = auth.uid() or public.is_household_owner(household_id));

-- Aporte/retiro atómico (clamp a 0). Cualquier miembro del household.
create or replace function public.add_savings_contribution(goal_id uuid, p_amount numeric)
returns void language plpgsql security definer set search_path = public as $$
declare hid uuid;
begin
  select household_id into hid from public.savings_goals where id = goal_id;
  if hid is null or not public.is_household_member(hid) then
    raise exception 'No autorizado';
  end if;
  update public.savings_goals
    set current_amount = greatest(0, current_amount + p_amount)
    where id = goal_id;
end; $$;
