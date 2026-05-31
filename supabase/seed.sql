-- =====================================================================
-- Astrea Budget — Datos de ejemplo (seed)
-- =====================================================================
-- Cómo usar:
--   1. Regístrate en la app (esto crea tu usuario y las categorías por
--      defecto vía trigger).
--   2. Obtén tu user_id en Supabase: Authentication → Users.
--   3. Reemplaza '00000000-0000-0000-0000-000000000000' por tu uuid.
--   4. Ejecuta este script en el SQL Editor.
-- =====================================================================

do $$
declare
  v_user        uuid := '00000000-0000-0000-0000-000000000000'; -- <-- TU user_id
  v_month       date := date_trunc('month', current_date)::date;
  cat_sueldo    uuid;
  cat_vivienda  uuid;
  cat_comida    uuid;
  cat_subs      uuid;
  svc_arriendo  uuid;
  svc_netflix   uuid;
  pay_arriendo  uuid;
begin
  -- Recupera categorías por defecto del usuario.
  select id into cat_sueldo   from public.categories where user_id = v_user and name = 'Sueldo' limit 1;
  select id into cat_vivienda from public.categories where user_id = v_user and name = 'Vivienda' limit 1;
  select id into cat_comida   from public.categories where user_id = v_user and name = 'Comida' limit 1;
  select id into cat_subs     from public.categories where user_id = v_user and name = 'Suscripciones' limit 1;

  -- Servicios.
  insert into public.services (user_id, name, type, category, estimated_amount, billing_day, frequency)
  values (v_user, 'Arriendo', 'fijo', 'esencial', 450000, 5, 'mensual')
  returning id into svc_arriendo;

  insert into public.services (user_id, name, type, category, estimated_amount, billing_day, frequency)
  values (v_user, 'Netflix', 'fijo', 'suscripcion', 9990, 15, 'mensual')
  returning id into svc_netflix;

  -- Ingreso del mes (sueldo).
  insert into public.transactions (user_id, type, amount, date, description, category_id)
  values (v_user, 'income', 1250000, v_month + 0, 'Sueldo mensual', cat_sueldo);

  -- Algunos gastos.
  insert into public.transactions (user_id, type, amount, date, description, category_id) values
    (v_user, 'expense', 28990, v_month + 3,  'Supermercado',     cat_comida),
    (v_user, 'expense', 15500, v_month + 9,  'Feria',            cat_comida),
    (v_user, 'expense', 9990,  v_month + 14, 'Netflix',          cat_subs);

  -- Pago pendiente del arriendo (vence este mes).
  insert into public.service_payments (service_id, user_id, due_date, amount, status)
  values (svc_arriendo, v_user, v_month + 4, 450000, 'pendiente')
  returning id into pay_arriendo;

  -- Pago de Netflix ya realizado este mes.
  insert into public.service_payments (service_id, user_id, due_date, amount, status, paid_date)
  values (svc_netflix, v_user, v_month + 14, 9990, 'pagado', v_month + 14);
end $$;
