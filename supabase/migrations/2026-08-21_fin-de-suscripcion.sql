-- =====================================================================
-- Fecha de término de un servicio fijo.
-- Aplicar sobre una base ya creada con schema.sql.
-- (schema.sql ya incluye este cambio para instalaciones nuevas.)
-- =====================================================================
--
-- "Cancelé la suscripción pero corre hasta diciembre": hasta ahora la única
-- opción era pausar el servicio (y perder los cobros que faltan) o acordarse
-- de pausarlo el mes exacto. Con esta columna el ciclo se apaga solo.
--
-- Se puede pegar completo en el SQL Editor: es idempotente.

alter table public.services
  add column if not exists last_charge_month date;

comment on column public.services.last_charge_month is
  'Mes (día 1) del último cobro. Null = sin fecha de término.';
