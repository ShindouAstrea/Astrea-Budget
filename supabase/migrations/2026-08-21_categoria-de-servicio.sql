-- =====================================================================
-- Categoría de gasto por servicio.
-- Aplicar sobre una base ya creada con schema.sql.
-- (schema.sql ya incluye este cambio para instalaciones nuevas.)
-- =====================================================================
--
-- Hasta ahora el gasto que genera "marcar pagado" nacía sin categoría, así que
-- los servicios fijos no contaban en los presupuestos por categoría ni en el
-- gráfico del dashboard (caían en "Sin categoría"). Con esta columna, cada
-- servicio recuerda a qué categoría de gasto imputar sus pagos.
--
-- Se puede pegar completo en el SQL Editor: es idempotente.

alter table public.services
  add column if not exists category_id uuid
    references public.categories (id) on delete set null;

create index if not exists services_category_idx
  on public.services (category_id);
