-- =====================================================================
-- Astrea Budget — Datos de ejemplo (seed)
-- =====================================================================
-- Cómo usar:
--   1. Regístrate en la app (esto crea tu usuario, perfil, household
--      personal, cuenta "Principal" y categorías por defecto vía trigger).
--   2. Obtén tu user_id en Supabase: Authentication → Users.
--   3. Reemplaza '00000000-0000-0000-0000-000000000000' por tu uuid.
--   4. Ejecuta este script en el SQL Editor.
-- =====================================================================

do $$
declare
  v_user        uuid := '00000000-0000-0000-0000-000000000000'; -- <-- TU user_id
  v_house       uuid;
  v_account     uuid;
  v_month       date := date_trunc('month', current_date)::date;
  cat_sueldo    uuid;
  cat_comida    uuid;
  cat_subs      uuid;
  svc_arriendo  uuid;
  svc_netflix   uuid;
begin
  -- Household personal y cuenta por defecto creados por el trigger.
  select id into v_house   from public.households where created_by = v_user and is_personal limit 1;
  select id into v_account from public.accounts  where household_id = v_house order by created_at limit 1;

  -- Categorías por defecto del household.
  select id into cat_sueldo from public.categories where household_id = v_house and name = 'Sueldo' limit 1;
  select id into cat_comida from public.categories where household_id = v_house and name = 'Comida' limit 1;
  select id into cat_subs   from public.categories where household_id = v_house and name = 'Suscripciones' limit 1;

  -- Servicios (estructura → autor = owner del household).
  insert into public.services (household_id, user_id, name, type, category, estimated_amount, billing_day, frequency)
  values (v_house, v_user, 'Arriendo', 'fijo', 'esencial', 450000, 5, 'mensual')
  returning id into svc_arriendo;

  insert into public.services (household_id, user_id, name, type, category, estimated_amount, billing_day, frequency)
  values (v_house, v_user, 'Netflix', 'fijo', 'suscripcion', 9990, 15, 'mensual')
  returning id into svc_netflix;

  -- Ingreso del mes (sueldo).
  insert into public.transactions (household_id, user_id, account_id, type, amount, date, description, category_id)
  values (v_house, v_user, v_account, 'income', 1250000, v_month + 0, 'Sueldo mensual', cat_sueldo);

  -- Algunos gastos.
  insert into public.transactions (household_id, user_id, account_id, type, amount, date, description, category_id) values
    (v_house, v_user, v_account, 'expense', 28990, v_month + 3,  'Supermercado', cat_comida),
    (v_house, v_user, v_account, 'expense', 15500, v_month + 9,  'Feria',        cat_comida),
    (v_house, v_user, v_account, 'expense', 9990,  v_month + 14, 'Netflix',      cat_subs);

  -- Pago pendiente del arriendo (vence este mes).
  insert into public.service_payments (household_id, service_id, user_id, due_date, amount, status)
  values (v_house, svc_arriendo, v_user, v_month + 4, 450000, 'pendiente');

  -- Pago de Netflix ya realizado este mes.
  insert into public.service_payments (household_id, service_id, user_id, due_date, amount, status, paid_date)
  values (v_house, svc_netflix, v_user, v_month + 14, 9990, 'pagado', v_month + 14);
end $$;
