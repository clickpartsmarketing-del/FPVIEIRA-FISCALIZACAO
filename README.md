# O.S. Fiscalização — SEMDE Rio das Ostras

App de **arquivo único** (`index.html`, zero dependências, sem build) para a fiscalização
emitir Ordens de Serviço com **numeração automática sequencial**, saída em **Excel (.xlsx)
no modelo oficial da Secretaria** (timbre embutido no arquivo) e compartilhamento por
WhatsApp e e-mail.

**Dois modos, mesmo arquivo:**
- `NUVEM` vazia → **modo local** (um aparelho, localStorage) — funciona offline, zero setup.
- `NUVEM` preenchida (url + anon do Supabase) → **sistema central**: contador único de
  numeração no servidor (vários fiscais sem colisão), login de verdade (Supabase Auth)
  e dados compartilhados. Setup completo em [`supabase/DEPLOY.md`](supabase/DEPLOY.md)
  e [`supabase/setup.sql`](supabase/setup.sql).

Infra padrão da casa: GitHub (`clickpartsmarketing-del/FPVIEIRA-FISCALIZACAO`) →
Vercel (estático, Framework *Other*) → Supabase.

Criado em 31/08/2026 a pedido do gestor Lucas, para mitigar as O.S. emergenciais:
o pedido nasce no grupo de WhatsApp → o fiscal emite a O.S. na hora pelo app →
o número nunca repete nem pula → depois marca **Executada / Não executada** e
exporta a **planilha de controle** (as "contas" do que foi feito e do que não).

## Login (v3)

Tela de entrada com a marca da Prefeitura (ponte, recriada em SVG — trocar pelo PNG
oficial quando disponível). Usuários: **Cássio** (chefe da fiscalização), **Renato**
e **Wellington**. Senhas iniciais: `cassio26` / `renato26` / `wellington26` — cada um
troca a sua nos Ajustes; o chefe pode redefinir a dos demais para o padrão.
Quem está logado sai registrado em cada O.S. (coluna EMITIDA POR no controle).
⚠ É identificação **local** (dados no aparelho) — autenticação de servidor é a fase 2.

## Como usar

- **Celular ou PC:** basta abrir o `index.html` (funciona offline, sem instalação).
  Pode mandar o próprio arquivo pelo WhatsApp — a pessoa toca e abre no navegador.
- **Ou publicar na Vercel** (padrão dos outros apps FPV): repo no GitHub → import na
  Vercel → framework *Other/None* (é estático, sem build).

## Regras da contagem

- O app segue em **2261** (contagem oficial chegou a 2260 por e-mail em 01/09/2026;
  aparelhos que já tinham dados são elevados a 2261 automaticamente, uma vez só).
- O número é atribuído ao emitir e **fica travado para sempre** — cancelou, o número
  não volta para a fila.
- A contagem vive no aparelho (`localStorage`). **Emitir sempre pelo mesmo aparelho**,
  ou combinar faixas de número entre aparelhos. Contador central (Supabase, vários
  aparelhos simultâneos) é a fase 2 — mesmo padrão da sequência `seq_fict` do FPV Campo.

## Saídas

1. **O.S. individual (.xlsx)** — réplica do modelo oficial (`OS n - ASSUNTO - ÁREA -
   UNIDADE.xlsx`), com timbre, mesmos rótulos e posições que o robô de e-mail já lê
   (`Nº OS`, `DATA DE ABERTURA`, `UNIDADE:`, `ÁREA:`, `ASSUNTO:`, `DESCRIÇÃO DO
   SERVIÇO`, `PRAZO:` …). Enviada por e-mail com assunto `OS n` para a caixa
   `fp.edu.riodasostras@gmail.com`, entra na esteira existente (n8n → Drive → app).
2. **Planilha de controle (.xlsx)** — abas CONTROLE (todas as O.S. com vínculo,
   execução e situação) e RESUMO (contas).
3. **Backup JSON** — exportar/importar na aba Ajustes.

## Manutenção

- Tudo vive em um único `index.html`. O timbre está embutido em base64
  (extraído do xlsx oficial da SEMDE — `xl/media/image1.jpeg`).
- Gerador de xlsx próprio (zip STORE + XML), sem bibliotecas externas.
- Listas editáveis no topo do `<script>`: `ESCOLAS`, `AREAS`, `NIVEIS`, `FISCAIS`,
  e o e-mail padrão em `carregar()`.
