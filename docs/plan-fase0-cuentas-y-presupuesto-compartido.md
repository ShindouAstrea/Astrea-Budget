# Fase 0 — Cuentas múltiples (#8) + Presupuesto compartido (#9)

> Plan de diseño. **No implementa código todavía.** Es la base estructural sobre
> la que se construyen las features #1–#5 y #7. Decisiones de esquema y RLS aquí
> evitan migraciones dolorosas más adelante.

## 0. Resumen ejecutivo

Hoy cada fila es de **un usuario** (`user_id` + RLS `auth.uid() = user_id`).
Para compartir un presupuesto entre personas (#9) necesitamos cambiar la unidad
de propiedad de **usuario** a **household** (hogar / presupuesto compartido).
Para cuentas múltiples (#8) agregamos una tabla `accounts` y un `account_id` a
las transacciones.

Decisión central adoptada (acordada con el usuario): **hacer #8 y #9 primero**,
juntas, porque ambas redefinen el modelo de propiedad y las foreign keys.

**Patrón elegido:** *household como frontera de aislamiento (multi-tenant)*.
- Se crea `households` + `household_members`.
- Todas las tablas de dominio ganan `household_id`.
- RLS pasa de "soy el dueño" a "soy miembro del household".
- `user_id` se conserva en cada fila como **autoría/auditoría** (quién creó el
  registro), no como control de acceso.

---

## 1. Modelo de datos nuevo

### 1.1 `households` — el presupuesto compartido
```sql
create table public.households (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  is_personal boolean not null default false,  -- el personal no se borra ni se abandona; sólo 1 por usuario
  created_by  uuid not null references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now()
);
```
Cada usuario tiene **exactamente un household personal** (creado en el registro,
`is_personal = true`) y puede **crear o unirse hasta a 3 households compartidos**
(`is_personal = false`). Es decir, máximo 4 households por usuario. El límite se
aplica al crear/aceptar (ver §5). El personal no se puede abandonar ni borrar.

### 1.2 `household_members` — membresía y rol
```sql
create type household_role as enum ('owner', 'member');

create table public.household_members (
  household_id uuid not null references public.households (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  role         household_role not null default 'member',
  joined_at    timestamptz not null default now(),
  primary key (household_id, user_id)
);

create index household_members_user_idx on public.household_members (user_id);
```

### 1.3 `accounts` — cuentas / billeteras (#8)
```sql
create type account_type as enum ('efectivo', 'debito', 'credito', 'ahorro');

create table public.accounts (
  id              uuid primary key default gen_random_uuid(),
  household_id    uuid not null references public.households (id) on delete cascade,
  user_id         uuid not null references auth.users (id) on delete cascade, -- creador
  name            text not null,
  type            account_type not null default 'debito',
  initial_balance numeric(14,2) not null default 0,
  -- Campos de tarjeta de crédito (sólo aplican cuando type = 'credito'):
  credit_limit     numeric(14,2) check (credit_limit >= 0),     -- cupo total
  statement_day    smallint check (statement_day between 1 and 28),    -- día de cierre/corte
  payment_due_day  smallint check (payment_due_day between 1 and 28),  -- día de vencimiento de pago
  color           text not null default '#2563EB',
  icon            text not null default 'account_balance_wallet',
  archived        boolean not null default false,
  created_at      timestamptz not null default now(),
  -- Coherencia: los campos de crédito sólo se llenan en cuentas de crédito.
  constraint credit_fields_only_for_credit check (
    type = 'credito' or (credit_limit is null and statement_day is null and payment_due_day is null)
  )
);

create index accounts_household_idx on public.accounts (household_id);
```
**Saldo de una cuenta** = `initial_balance + Σ ingresos − Σ gastos` de sus
transacciones. Se calcula (no se almacena) para evitar desincronización; ver §4.

**Cuentas de crédito (#3 resuelto):** el saldo será típicamente negativo (deuda).
- **Cupo disponible** = `credit_limit + balance` (con `balance` ≤ 0).
- `statement_day` y `payment_due_day` permiten mostrar "tu próxima factura cierra
  el día X, se paga el día Y" y, más adelante, generar el recordatorio de pago de
  la tarjeta reusando el motor de notificaciones existente.

### 1.4 Columnas añadidas a tablas existentes
```sql
alter table public.categories       add column household_id uuid references public.households (id) on delete cascade;
alter table public.services         add column household_id uuid references public.households (id) on delete cascade;
alter table public.transactions     add column household_id uuid references public.households (id) on delete cascade;
alter table public.service_payments add column household_id uuid references public.households (id) on delete cascade;

-- #8: a qué cuenta pertenece cada movimiento.
alter table public.transactions add column account_id uuid references public.accounts (id) on delete set null;

-- Transferencias entre cuentas (opción A): un gasto en origen + un ingreso en
-- destino comparten este id. Las filas con transfer_group_id NO son ingreso/gasto
-- "real" y se excluyen del resumen del dashboard.
alter table public.transactions add column transfer_group_id uuid;

create index transactions_account_idx on public.transactions (account_id);
create index transactions_transfer_idx on public.transactions (transfer_group_id);
create index transactions_household_date_idx on public.transactions (household_id, date desc);
```
(Tras el backfill de §3, `household_id` pasa a `not null`.)

---

## 2. Row Level Security — de "dueño" a "miembro"

### 2.1 Función helper (evita recursión y repetición)
RLS que consulta `household_members` desde políticas de otras tablas debe ir por
una función `security definer`, si no Postgres puede entrar en recursión de
políticas y además repetir el subselect en todas las tablas.
```sql
create or replace function public.is_household_member(hid uuid)
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.household_members
    where household_id = hid and user_id = auth.uid()
  );
$$;
```

### 2.2 Políticas de dominio — dos niveles de escritura (#4 resuelto)

Decisión: **lectura compartida siempre** (cualquier miembro ve todo el household,
para transparencia), pero la **escritura** tiene dos niveles según la naturaleza
del dato:

| Nivel | Tablas | SELECT | INSERT | UPDATE / DELETE |
|-------|--------|--------|--------|-----------------|
| **A. Movimientos** (lo que registra cada persona) | `transactions` | todos los miembros | propio (`user_id = auth.uid()`) | **sólo el autor** (`user_id = auth.uid()`) |
| **B. Estructura** (andamiaje del presupuesto) | `accounts`, `categories`, `services` | todos los miembros | sólo `owner` | sólo `owner` |
| **C. Pagos** (híbrido) | `service_payments` | todos los miembros | cualquier miembro | cualquier miembro |

> **`service_payments` es un caso aparte (Nivel C).** Un servicio recurrente
> (`services`, Nivel B) lo define el `owner`, pero **cualquier miembro puede
> pagarlo**: marcar un pago como pagado crea una `transaction` de gasto con el
> `user_id` de quien paga (su propio movimiento, Nivel A). Por eso `service_payments`
> permite insert/update a cualquier miembro, pero la transacción resultante queda
> a nombre del que pagó. La generación mensual (`generateMonthlyPayments`) la
> dispara quien abra el dashboard; el `unique (service_id, due_date)` evita
> duplicados aunque dos miembros la disparen.

> **Por qué.** El usuario pidió que cada quien edite *sólo lo suyo* — más
> transparente y seguro. Los **movimientos** son responsabilidad de quien los
> creó. La **estructura** (cuentas y categorías) es el andamiaje común; lo
> mantiene el `owner` del household para conservar una taxonomía coherente. En el
> household personal `creador = owner = autor`, así que no hay diferencia
> práctica; los niveles sólo se notan en households compartidos.

Helper de owner (análogo a `is_household_member`, evita repetición/recursión):
```sql
create or replace function public.is_household_owner(hid uuid)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.household_members
    where household_id = hid and user_id = auth.uid() and role = 'owner');
$$;
```

**Nivel A — sólo `transactions`** (escritura por autor):
```sql
drop policy if exists "transactions_select" on public.transactions;
drop policy if exists "transactions_insert" on public.transactions;
drop policy if exists "transactions_update" on public.transactions;
drop policy if exists "transactions_delete" on public.transactions;

create policy "transactions_select" on public.transactions
  for select using (public.is_household_member(household_id));
create policy "transactions_insert" on public.transactions
  for insert with check (public.is_household_member(household_id) and user_id = auth.uid());
create policy "transactions_update" on public.transactions
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "transactions_delete" on public.transactions
  for delete using (user_id = auth.uid());
```

**Nivel C — `service_payments`** (cualquier miembro puede pagar/generar):
```sql
create policy "service_payments_select" on public.service_payments
  for select using (public.is_household_member(household_id));
create policy "service_payments_insert" on public.service_payments
  for insert with check (public.is_household_member(household_id));
create policy "service_payments_update" on public.service_payments
  for update using (public.is_household_member(household_id))
              with check (public.is_household_member(household_id));
create policy "service_payments_delete" on public.service_payments
  for delete using (public.is_household_member(household_id));
```

**Nivel B — ejemplo `accounts`** (idéntico para `categories` y `services`):
```sql
create policy "accounts_select" on public.accounts
  for select using (public.is_household_member(household_id));
create policy "accounts_insert" on public.accounts
  for insert with check (public.is_household_owner(household_id) and user_id = auth.uid());
create policy "accounts_update" on public.accounts
  for update using (public.is_household_owner(household_id))
              with check (public.is_household_owner(household_id));
create policy "accounts_delete" on public.accounts
  for delete using (public.is_household_owner(household_id));
```
> ⚠️ **Implicación de UX a validar:** con el Nivel A estricto, si tu pareja añade
> un gasto mal, tú no puedes corregirlo (sólo ella). Es lo pedido (seguro y
> transparente). Si más adelante se quiere que el `owner` también pueda corregir
> movimientos ajenos, se añade `or public.is_household_owner(household_id)` al
> `using` de update/delete de Nivel A.

### 2.3 Políticas de `households` y `household_members`
```sql
alter table public.households       enable row level security;
alter table public.household_members enable row level security;
grant select, insert, update, delete on public.households, public.household_members, public.accounts to authenticated;

-- households: ver/usar los que integro; sólo el owner edita/borra.
create policy "households_select" on public.households
  for select using (public.is_household_member(id));
create policy "households_insert" on public.households
  for insert with check (created_by = auth.uid());
create policy "households_update" on public.households
  for update using (exists (select 1 from public.household_members
    where household_id = id and user_id = auth.uid() and role = 'owner'));
create policy "households_delete" on public.households
  for delete using (created_by = auth.uid());

-- household_members: cada quien ve las membresías de SUS households.
-- Inserciones controladas vía RPC de invitación (§5), no insert directo libre.
create policy "members_select" on public.household_members
  for select using (public.is_household_member(household_id));
create policy "members_delete" on public.household_members
  for delete using (
    user_id = auth.uid()  -- puedo salirme yo
    or exists (select 1 from public.household_members m  -- o el owner me saca
      where m.household_id = household_members.household_id
        and m.user_id = auth.uid() and m.role = 'owner')
  );
```
> ⚠️ **Riesgo de recursión:** `members_select` referencia `household_members`
> vía `is_household_member` (que es `security definer`, así que no aplica RLS
> dentro → corta la recursión). Validar en un entorno de prueba antes de prod.

---

## 3. Migración: reconstrucción (decisión tomada)

> **Resuelto:** la BD sólo tiene **datos de prueba** del usuario y hay **un único
> entorno Supabase** (sin staging). Por eso NO se hace backfill incremental: se
> **reconstruye desde cero**. El `supabase/schema.sql` ya está reescrito con el
> modelo nuevo (incluye un bloque 0 de `drop ... cascade` idempotente) y
> `supabase/seed.sql` actualizado al modelo household. Flujo: correr `schema.sql`
> → registrarse en la app (el trigger crea perfil + household personal + cuenta +
> categorías) → opcionalmente correr `seed.sql` con tu `user_id`.
>
> El backfill incremental de abajo se conserva sólo como **referencia** por si en
> el futuro hay datos reales que migrar en caliente.

### (Referencia — backfill incremental, NO se usa ahora)

1. Crear las tablas/columnas nuevas (§1) con `household_id` **nullable**.
2. **Un household personal por usuario existente** y su membresía `owner`:
```sql
insert into public.households (id, name, is_personal, created_by)
select gen_random_uuid(), 'Personal', true, u.id from auth.users u
on conflict do nothing;

insert into public.household_members (household_id, user_id, role)
select h.id, h.created_by, 'owner' from public.households h
on conflict do nothing;
```
3. **Backfill** de `household_id` en cada tabla, mapeando por `user_id`:
```sql
update public.transactions t set household_id = h.id
  from public.households h where h.created_by = t.user_id and t.household_id is null;
-- repetir para categories, services, service_payments
```
4. **Cuenta por defecto** por household y asignarla a las transacciones:
```sql
insert into public.accounts (household_id, user_id, name, type)
select h.id, h.created_by, 'Principal', 'debito' from public.households h;

update public.transactions t set account_id = a.id
  from public.accounts a where a.household_id = t.household_id and t.account_id is null;
```
5. Poner `household_id` en `not null` y dejar las políticas nuevas activas.

> Hacer la migración en una transacción y probar en un proyecto Supabase de
> staging con copia de datos antes de tocar producción.

---

## 4. Cálculo de saldos de cuenta (#8)

Vista de apoyo (lectura simple desde el cliente, respeta RLS de la cuenta):
```sql
create or replace view public.account_balances as
select
  a.id as account_id,
  a.household_id,
  a.initial_balance
    + coalesce(sum(case when t.type = 'income'  then t.amount else 0 end), 0)
    - coalesce(sum(case when t.type = 'expense' then t.amount else 0 end), 0)
    as balance
from public.accounts a
left join public.transactions t on t.account_id = a.id
group by a.id;
```
Alternativa sin vista: calcularlo en un provider Riverpod sumando las
transacciones ya cargadas. Para empezar, **provider en el cliente** es suficiente
y evita mantener una vista; la vista se añade si el volumen crece.

### Transferencias entre cuentas (opción A — resuelto)
Mover dinero de "Débito" a "Ahorro" no es ingreso ni gasto y **no debe contar**
en el resumen del dashboard. Se modela como **par de transacciones enlazadas por
`transfer_group_id`** (§1.4): un `expense` en la cuenta origen y un `income` en la
cuenta destino, ambos con el mismo `transfer_group_id`.
- Para saldos de cuenta: cuentan normalmente (restan del origen, suman al destino).
- Para el dashboard: `monthSummaryProvider` debe filtrar `transfer_group_id == null`
  para no inflar ingresos/gastos del mes.
- En la app, crear una transferencia inserta las **dos** filas en una sola acción
  (idealmente vía un RPC `create_transfer` para atomicidad, o dos inserts
  secuenciales con manejo de error).

---

## 5. Flujo de invitación / compartir (#9)

Supabase no expone `auth.users` al cliente, así que no se puede buscar a otro
usuario por email directamente. Patrón estándar: **tabla de invitaciones que el
invitado consulta por su propio email**.
```sql
create type invitation_status as enum ('pending', 'accepted', 'declined', 'expired');

create table public.household_invitations (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  email        text not null,                 -- a quién se invita
  invited_by   uuid not null references auth.users (id) on delete cascade,
  status       invitation_status not null default 'pending',
  created_at   timestamptz not null default now(),
  expires_at   timestamptz not null default now() + interval '7 days'
);
```
- **RLS select:** el owner ve las invitaciones que emitió; el invitado ve las
  que coinciden con su email (`lower(email) = lower(auth.jwt()->>'email')`).
- **Aceptar:** RPC `security definer` que valida la invitación y crea la
  membresía (el invitado no puede insertar en `household_members` directamente):
```sql
create or replace function public.accept_invitation(invitation_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare inv public.household_invitations; shared_count int;
begin
  select * into inv from public.household_invitations where id = invitation_id;
  if inv is null or inv.status <> 'pending' or inv.expires_at < now() then
    raise exception 'Invitación inválida o expirada';
  end if;
  if lower(inv.email) <> lower(auth.jwt()->>'email') then
    raise exception 'La invitación no es para este usuario';
  end if;
  -- Límite: máximo 3 households COMPARTIDOS por usuario (#2).
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
```
> El **mismo límite de 3** se valida al *crear* un household compartido. Conviene
> hacerlo con un trigger `before insert on households` (cuando `is_personal =
> false`) que cuente los compartidos del creador, para que la regla viva en la BD
> y no sólo en la app. La app además lo refleja deshabilitando el botón "crear
> presupuesto" al llegar al tope.

---

## 6. Onboarding: nuevo `handle_new_user`

El trigger actual siembra categorías con `user_id`. Debe, además, crear el
household personal, la membresía y sembrar las categorías **en ese household**:
```sql
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare hid uuid;
begin
  insert into public.households (name, is_personal, created_by) values ('Personal', true, new.id)
    returning id into hid;
  insert into public.household_members (household_id, user_id, role)
    values (hid, new.id, 'owner');
  insert into public.accounts (household_id, user_id, name, type)
    values (hid, new.id, 'Principal', 'debito');
  insert into public.categories (household_id, user_id, name, type, icon, color, is_default) values
    (hid, new.id, 'Sueldo', 'income', 'payments', '#16A34A', true),
    -- ... (resto de categorías por defecto con hid + new.id)
    (hid, new.id, 'Otros gastos', 'expense', 'more_horiz', '#64748B', true);
  return new;
end; $$;
```

---

## 7. Cambios en la app Flutter

### 7.1 Estado nuevo (Riverpod, escritos a mano por el conflicto de codegen)
- `currentHouseholdProvider` — household activo, persistido en SharedPreferences
  (key `current_household_id`); default = el personal. Un selector para cambiar
  entre households a los que pertenece el usuario.
- `householdsProvider` / `householdMembersProvider` — lista de households y
  miembros (para la pantalla de compartir).
- `accountsProvider` — cuentas del household activo.
- `currentAccountProvider` — cuenta por defecto en el formulario de transacción
  (persistida).
- `accountBalancesProvider` — saldo calculado por cuenta.

### 7.2 Dominios nuevos (`freezed`)
`Household`, `HouseholdMember`, `Account`, `HouseholdInvitation` + un enum
`AccountType` en `lib/shared/enums.dart` (con `wire`/`label`, espejando el resto).

### 7.3 Repositorios — el cambio transversal
Hoy cada repo hace `'user_id': _uid` en los `insert`. Pasa a incluir también
`'household_id': <household activo>`. Afecta:
- [transaction_repository.dart](../lib/features/transactions/data/transaction_repository.dart):
  `create`/`update` añaden `household_id` y `account_id`; `fetchBetween` filtra
  por household activo (RLS ya lo garantiza, pero conviene filtrar explícito si
  hay varios households cargados).
- [service_repository.dart](../lib/features/services/data/service_repository.dart):
  `createService`, `createPayment`, `generateMonthlyPayments`, `markAsPaid`
  añaden `household_id`.
- `category_repository.dart` análogo.
- Nuevos: `account_repository.dart`, `household_repository.dart`.

### 7.4 UI nueva
- **Selector de cuenta** en [transaction_form_page.dart](../lib/features/transactions/presentation/transaction_form_page.dart).
- **Pantalla "Cuentas"**: lista con saldos, crear/editar/archivar, transferir.
- **Selector de household** (en AppBar o ajustes) si pertenece a >1.
- **Pantalla "Compartir presupuesto"** en ajustes: invitar por email, lista de
  miembros con rol, salir / quitar miembro, bandeja de invitaciones recibidas.
- Dashboard: filtro/segmentación de saldos por cuenta (opcional, fase posterior).
- Rutas nuevas en [routes.dart](../lib/core/router/routes.dart): `accounts`,
  `accountForm`, `sharing`.

---

## 8. Decisiones (resueltas con el usuario)

1. ✅ **Transferencias** → **opción A**: par de transacciones enlazadas por
   `transfer_group_id`, excluidas del resumen (§4).
2. ✅ **Multi-household** → **1 personal por defecto** + crear/unirse a hasta
   **3 compartidos** (máx. 4 en total). Límite aplicado en BD y reflejado en UI
   (§1.1, §5).
3. ✅ **Cuentas de crédito** → modeladas **con cupo y facturación**
   (`credit_limit`, `statement_day`, `payment_due_day`) (§1.3).
4. ✅ **Roles** → cada quien edita **sólo lo suyo**: lectura compartida, escritura
   de movimientos por autor y de estructura por owner (§2.2).

### Pendiente de validar (operativo, no de diseño)
- **Email del invitado en el JWT** — la RPC `accept_invitation` y la policy del
  invitado dependen de `auth.jwt()->>'email'`. Confirmar en la config de Supabase
  Auth que el email viaja en el token.
- **Recursión de RLS** — probar las políticas de `household_members` en staging.
- **Atomicidad de transferencias** — decidir si se usa un RPC `create_transfer`
  (recomendado) o dos inserts con rollback manual.

---

## 9. Orden de implementación sugerido (sub-fases)

| Paso | Contenido | Riesgo |
|------|-----------|--------|
| 0.1 | Migración SQL: `households`, `members`, `household_id`, RLS, backfill | **Alto** (datos) |
| 0.2 | `accounts` + `account_id` + cuenta por defecto + saldos | Medio |
| 0.3 | App: providers de household/cuenta + cambios en repos | Medio |
| 0.4 | UI cuentas (lista, form, transferencias) | Bajo |
| 0.5 | Invitaciones + RPC + UI de compartir (#9) | Medio |

Cada paso es desplegable y testeable por separado. **0.1 es el punto sin retorno**
y debe probarse en staging con copia de datos reales antes de producción.

---

## 10. Impacto en las features siguientes (por qué esta base primero)

- **#1 Presupuestos por categoría** → la tabla `budgets` llevará `household_id`,
  no `user_id`. Diseñarla después de esto evita migrarla.
- **#3 Metas de ahorro** → idem; además podrá asociarse a una `account` de tipo
  `ahorro`.
- **#7 Transacciones recurrentes** → la plantilla llevará `household_id` y
  `account_id` desde el día uno.
- **#2 Tendencias / #4 Proyección / #5 Recurrentes** → sólo lectura; heredan el
  filtrado por household automáticamente vía RLS.
