# Deploy — GitHub + Supabase + Vercel (padrão da casa)

O app é **um arquivo estático** (`index.html`, sem build/Vite): a Vercel só serve o
arquivo. Com `NUVEM` vazia ele roda 100% local; preenchida, vira o sistema central
(contador único + logins + dados compartilhados).

## 1. Supabase (uma vez)

1. [supabase.com](https://supabase.com) → **New project** (free tier serve).
2. **SQL Editor** → colar o conteúdo de `supabase/setup.sql` → **Run**.
   Conferência no fim: tabela com 0 linhas · sequence em 2261.
3. **Alinhar a contagem no go-live** (a oficial anda todo dia):
   ```sql
   select setval('seq_os_fisc', ULTIMA_OFICIAL_JA_EMITIDA);
   ```
   (ex.: última foi 2260 → `setval(..., 2260)` → a próxima emitida sai 2261)
4. **Authentication → Users → Add user** (marcar *Auto Confirm*), 3 contas:
   | usuário | e-mail (sintético) |
   |---|---|
   | Cássio | `cassio@fpvfisc.app` |
   | Renato | `renato@fpvfisc.app` |
   | Wellington | `wellington@fpvfisc.app` |
   Senha inicial forte (mín. 6); cada um troca depois nos Ajustes do app.
   Esqueceu a senha → admin redefine aqui mesmo (Users → ⋯ → Reset password).

## 2. Ligar o app na nuvem

1. **Settings → API**: copiar `Project URL` e a chave **anon public**.
2. No `index.html`, preencher (perto do topo do script):
   ```js
   const NUVEM = {
     url:  'https://SEU-PROJETO.supabase.co',
     anon: 'CHAVE_ANON_PUBLIC'
   };
   ```
3. Commit + push → a Vercel redeploya sozinha.

⚠ **NUNCA** colar a `service_role` no app, no repo ou na Vercel — só a anon
(lição aprendida no contrato da Saúde). A anon no arquivo é pública por
design; quem protege os dados é a RLS.

## 3. Vercel (uma vez)

1. vercel.com → **Add New → Project** → importar `clickpartsmarketing-del/FPVIEIRA-FISCALIZACAO`.
2. Framework Preset: **Other** · sem build command · output padrão. Deploy.
3. Push na `main` = produção.

## 4. Teste de aceite (2 celulares)

1. Abrir a URL da Vercel nos 2, logar com usuários diferentes.
2. Emitir uma O.S. em cada um, quase ao mesmo tempo → números **diferentes e
   sequenciais** (o servidor é quem numera).
3. Marcar "Executada" num aparelho → ↻ no outro → status igual.
4. Baixar o Excel → modelo oficial com timbre, PRAZO em branco.

## Migração de aparelho que usava o modo local

Antes de abrir a versão com nuvem: **Ajustes → Exportar backup**. Ao logar na
nuvem, a lista passa a vir do servidor; O.S. antigas só-locais não sobem
sozinhas (me acione que eu importo o backup pro banco com os números certos).
