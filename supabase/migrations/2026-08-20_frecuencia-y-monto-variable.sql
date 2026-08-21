-- =====================================================================
-- Costos fijos: frecuencia real (bimestral/trimestral/semestral/anual/único)
-- y monto variable mes a mes.
-- Aplicar sobre una base ya creada con schema.sql.
-- (schema.sql ya incluye estos cambios para instalaciones nuevas.)
-- =====================================================================
--
-- Se puede pegar completo en el SQL Editor: es idempotente (se puede volver a
-- ejecutar sin efectos raros).
--
-- Nota de Postgres: un valor de enum recién agregado NO puede usarse como
-- literal en la misma transacción que lo creó ("unsafe use of new value").
-- Por eso el bloque 4 compara sobre `frequency::text` en vez de nombrar los
-- valores nuevos como enum.

-- ---------------------------------------------------------------------
-- BLOQUE 1 — nuevos valores de frecuencia
-- ---------------------------------------------------------------------
alter type service_frequency add value if not exists 'trimestral' before 'anual';
alter type service_frequency add value if not exists 'semestral'  before 'anual';

-- ---------------------------------------------------------------------
-- BLOQUE 2 — columnas nuevas
-- ---------------------------------------------------------------------

-- Ancla del ciclo para frecuencias NO mensuales: mes (día 1) del primer cobro.
-- Un servicio semestral anclado en marzo cobra en marzo y septiembre; el resto
-- de los meses no genera pago.
alter table public.services
  add column if not exists first_charge_month date;

-- Marca los pagos cuyo monto se ajustó a mano para ESE período. Los montos
-- ajustados no se pisan al editar el monto estimado del servicio.
alter table public.service_payments
  add column if not exists amount_overridden boolean not null default false;

-- ---------------------------------------------------------------------
-- BLOQUE 3 — backfill del ancla en servicios existentes
-- ---------------------------------------------------------------------
-- Se usa el primer vencimiento ya registrado; si no hay ninguno, el mes de
-- creación del servicio.
update public.services s
set first_charge_month = date_trunc(
      'month',
      coalesce(
        (select min(p.due_date) from public.service_payments p
          where p.service_id = s.id),
        s.created_at::date
      )
    )::date
where s.first_charge_month is null;

-- ---------------------------------------------------------------------
-- BLOQUE 4 (opcional) — limpiar pagos fantasma ya generados
-- ---------------------------------------------------------------------
-- Antes de este cambio, TODO servicio fijo con día de cobro generaba un pago
-- cada mes, incluidos los anuales/semestrales. Esto borra sólo los pagos
-- pendientes, sin transacción y sin monto ajustado, que caen en un mes que la
-- frecuencia del servicio no contempla.
--
-- Para revisar antes de borrar, reemplaza el `delete ... using` por:
--   select p.id, s.name, s.frequency, p.due_date from public.service_payments p
--   join public.services s on s.id = p.service_id where ...
delete from public.service_payments p
using public.services s
where p.service_id = s.id
  and p.status = 'pendiente'
  and p.transaction_id is null
  and p.amount_overridden = false
  and s.type = 'fijo'
  and s.first_charge_month is not null
  and s.frequency::text <> 'mensual'
  and s.frequency::text <> 'unico'
  and (
    -- meses transcurridos desde el ancla
    (extract(year from p.due_date) - extract(year from s.first_charge_month)) * 12
    + (extract(month from p.due_date) - extract(month from s.first_charge_month))
  ) % case s.frequency::text
        when 'bimestral'  then 2
        when 'trimestral' then 3
        when 'semestral'  then 6
        when 'anual'      then 12
        else 1
      end <> 0;

-- Los servicios de frecuencia 'unico' sólo tienen un cobro: el del mes ancla.
delete from public.service_payments p
using public.services s
where p.service_id = s.id
  and p.status = 'pendiente'
  and p.transaction_id is null
  and p.amount_overridden = false
  and s.type = 'fijo'
  and s.first_charge_month is not null
  and s.frequency::text = 'unico'
  and date_trunc('month', p.due_date)::date <> s.first_charge_month;
