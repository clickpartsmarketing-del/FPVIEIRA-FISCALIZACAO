-- =====================================================================
-- FPV FISCALIZAÇÃO — setup do Supabase (rodar 1x no SQL Editor)
-- Idempotente: rodar de novo não estraga nada.
-- Padrão da casa: contador central por sequence+trigger (como o seq_fict
-- do FPV Campo), RLS só p/ autenticados, DELETE proibido (número é
-- história — cancelamento é UPDATE).
-- =====================================================================

create table if not exists os_fiscalizacao (
  id            bigint generated always as identity primary key,
  numero        integer unique,
  data_abertura date        not null default ((now() at time zone 'America/Sao_Paulo'))::date,
  unidade       text        not null,
  area          text        not null default '',
  nivel         text        not null default 'I',
  assunto       text        not null default '',
  descricao     text        not null default '',
  fiscal        text        not null default '',
  emitida_por   text        not null default '',
  obs           text        not null default '',
  materiais     text        not null default '',
  status        text        not null default 'PEND',   -- PEND | SIM | NAO
  cancelada     boolean     not null default false,
  concluida_em  date,
  criado_em     timestamptz not null default now(),
  criado_por    uuid                 default auth.uid()
);

-- ---------------------------------------------------------------
-- CONTADOR CENTRAL — a numeração nasce AQUI, nunca no aparelho.
-- start 2261 = próxima após a última oficial conhecida (2260, 01/09/2026).
-- ⚠ NO GO-LIVE, alinhar com a contagem real do dia:
--     select setval('seq_os_fisc', <ÚLTIMA O.S. OFICIAL JÁ EMITIDA>);
--   (a próxima emitida sai <última>+1)
-- ---------------------------------------------------------------
create sequence if not exists seq_os_fisc start 2261;

create or replace function fisc_atribui_numero() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.numero is null then
    new.numero := nextval('seq_os_fisc');
  end if;
  return new;
end $$;

drop trigger if exists trg_fisc_numero on os_fiscalizacao;
create trigger trg_fisc_numero before insert on os_fiscalizacao
for each row execute function fisc_atribui_numero();

-- ---------------------------------------------------------------
-- SEGURANÇA: RLS só p/ logados; sem DELETE; nº e texto originais
-- imutáveis via privilégios de coluna (update só no acompanhamento).
-- ---------------------------------------------------------------
alter table os_fiscalizacao enable row level security;

drop policy if exists fisc_select on os_fiscalizacao;
create policy fisc_select on os_fiscalizacao
  for select to authenticated using (true);

drop policy if exists fisc_insert on os_fiscalizacao;
create policy fisc_insert on os_fiscalizacao
  for insert to authenticated with check (true);

drop policy if exists fisc_update on os_fiscalizacao;
create policy fisc_update on os_fiscalizacao
  for update to authenticated using (true) with check (true);

-- anon não faz nada; authenticated não deleta; update limitado às colunas
-- de acompanhamento (numero/descrição/unidade ficam imutáveis pela API)
revoke all    on os_fiscalizacao from anon;
revoke delete on os_fiscalizacao from authenticated;
revoke update on os_fiscalizacao from authenticated;
grant  update (status, cancelada, concluida_em, obs, materiais)
       on os_fiscalizacao to authenticated;

-- realtime (roadmap — o app hoje sincroniza ao trocar de aba/↻):
-- alter publication supabase_realtime add table os_fiscalizacao;

-- ---------------------------------------------------------------
-- CONFERÊNCIA (deve devolver: tabela com 0 linhas; last_value 2261)
-- ---------------------------------------------------------------
select 'os_fiscalizacao' as tabela, count(*) as linhas from os_fiscalizacao;
select last_value, is_called from seq_os_fisc;
