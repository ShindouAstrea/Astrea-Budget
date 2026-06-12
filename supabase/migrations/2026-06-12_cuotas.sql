-- Compras en cuotas: aplicar sobre una base ya creada con schema.sql.
-- (schema.sql ya incluye estas columnas para instalaciones nuevas.)

alter table public.transactions
  add column if not exists installment_group_id uuid,
  add column if not exists installments_total   int check (installments_total between 2 and 60),
  add column if not exists installment_number   int check (installment_number >= 1);

create index if not exists transactions_installment_idx
  on public.transactions (installment_group_id);
