# AI_State — estado vivo do projeto

## Para que serve

Este arquivo é a passagem de contexto do projeto **Tower Idle Adventure**. Deve permitir que uma pessoa ou agente retome o trabalho sem inventar decisões nem contradizer etapas anteriores. É um resumo vivo — não substitui o [GDD](GDD.md), as [especificações de sistemas](SYSTEMS_SPEC.md) e [combate](COMBAT_DESIGN.md), a [HUD/UX](HUD_UX_SPEC.md), a [arquitetura técnica](TECH_ARCHITECTURE.md), o [Painel Administrativo](ADMIN_PANEL_SPEC.md) nem o [Roadmap](ROADMAP.md).

### Protocolo obrigatório por etapa

1. **No início de cada etapa:** ler este arquivo primeiro; em seguida ler os documentos citados como fontes para a tarefa. Conferir o git status e identificar alterações existentes antes de editar.
2. Confirmar etapa/marco atual e escopo autorizado no Roadmap. Não iniciar implementação de gameplay antes do portão de aprovação de design.
3. Se houver ambiguidade, registrar a pergunta/decisão no documento relevante antes de codificar. Não apagar decisões anteriores sem registrar o motivo.
4. **Ao terminar cada etapa:** atualizar esta seção (data, entregue, decisões, pendências, próximos passos, testes/evidências), atualizar os documentos-fonte afetados e garantir que o Roadmap reflita o estado real.
5. Não marcar etapa concluída sem evidência verificável. Não alegar teste, lançamento ou sistema pronto que não tenha sido executado/feito.
6. **Checkpoint obrigatório ao final de toda etapa:** depois de atualizar este AI_State e os documentos afetados, fazer `git add` dos arquivos de progresso da etapa, criar um commit e fazer push para `origin arena/01a0e5e1-tower-idle-adventure`. Isso se aplica mesmo quando a etapa estiver incompleta, pausada ou ainda depender de decisões; registrar no commit/AI_State que o trabalho é parcial quando for o caso. Não esperar a conclusão integral da etapa para salvar o progresso. Conferir que o push terminou com sucesso e informar o hash do commit. Nunca trocar de branch nem enviar para outra branch. Se o push falhar, não afirmar que o checkpoint foi publicado: registrar a falha e tratar o envio como pendente.

## Situação atual

- **Data:** 2026-09-28.
- **Branch obrigatória da sessão:** `arena/01a0e5e1-tower-idle-adventure`.
- **Fase:** Etapa 2/G2 em andamento. Criados blueprints técnicos/ameaças/UX, click-through e migration-base de schema com harness PGlite. Não há gameplay, HUD real, Admin Web, Edge Functions ou serviço Supabase provisionado.
- **Marco atual:** G1 foi fechado documentalmente na etapa anterior. Baseline MVP continua como decisão do agente sob delegação explícita do usuário (adaptável), sem atribuir escolhas individuais ao usuário. G2 requer prova no Supabase CLI, revisão de segurança e usabilidade com participantes. O usuário confirmou que abriu e validou visualmente o protótipo; isso não substitui teste de usabilidade com 5–8 convidados.
- **Documentação atual:** README e quatorze arquivos Markdown em `docs/`, incluindo `PROJECT_STRUCTURE.md` e `DEPLOYMENT_GUIDE.md`; estrutura segue proposta, sem apps criados. Protótipo local `prototypes/g2-hud/index.html` (dados fictícios, sem APIs/backend) está sendo servido na porta 4173 para revisão; migration-base em `supabase/migrations/` e testes PGlite em `supabase/tests/`.
- **Validação desta etapa:** `npm ci --prefix supabase` + `npm test --prefix supabase` passaram (9/9) em PGlite 0.5.8/PostgreSQL 18.3; `npm audit` encontrou 0 vulnerabilidades conhecidas no harness. Config Supabase propõe PG15 (diferença de versão explícita). Nesta atualização, preview HTTP local respondeu 200; link-check em 15 arquivos Markdown/65 links relativos e `git diff --check` passaram. Sem validar serviço externo. PGlite simula roles/Auth e não valida Supabase CLI/PostgREST/Edge/Storage/concorrência/custos; CLI/Docker ausentes. Sem teste de segurança em serviço real nem estudo UX.

## Resumo confiável do projeto

**Tower Idle Adventure** é um RPG idle 2D para navegador. O MVP fechado é PvE individual, desktop-first, PT-BR e alpha por convite. Conta escolhe Guerreiro, Arcanista ou Ladino, monta equipe de até três, faz hunt individual em 10 andares, ganha XP/Coins/loot e retorna ao lobby; companheiros desbloqueiam nos andares 3 e 6. Nível compartilhado vai de 1–20. Há um boss solo recorrente no andar 10. A especificação numérica completa e critérios de aceite vivem em `MVP_DECISIONS.md`.

**Status importante:** escopo baseline foi decidido pelo agente após autorização explícita do usuário. Não tratar cada valor de `MVP_DECISIONS.md` como decisão individualmente escolhida ou aprovada pelo usuário. Pode ser adaptado futuramente por solicitação. Nenhuma feature/gameplay do produto foi implementada; fórmulas/valores precisam de playtest na vertical slice. A migration-base técnica é somente uma fundação G2 e não muda esse status.

O MVP tem 10 slots (Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet), oito stats por item, seis raridades e notas/poder definidos. Regra explicitamente confirmada pelo usuário: `x` independente por atributo, inteiro de 1–50; fator `x/10`, em passos de 0,1. `x=4,72` foi rejeitado. Qualquer personagem pode equipar qualquer arma. O baseline completo de combate/armas foi aprovado pelo usuário; Contracorte tem 20% de chance após ataque direto de alvo único e causa 50% do Ataque atual, sem recursão nem ativação por DoT. Valores podem mudar com evidência de playtest.

**Stack aprovada:** Game Web e Admin Web separados na Vercel; Supabase Auth/PostgreSQL/Edge Functions/Storage no backend. Cliente não decide combate, economia ou conteúdo. Painel CMS no-code fica isolado; jogadores comuns não veem sua interface nem acessam APIs administrativas. Existe migration-base de schema ainda não aplicada no Supabase; nenhum serviço, endpoint, gameplay ou aplicação web foi provisionado/implementado. Ver `TECH_ARCHITECTURE.md`, `ADMIN_PANEL_SPEC.md`, `G2_TECHNICAL_BLUEPRINT.md` e `THREAT_MODEL.md`.

**G2 UX:** `HUD_UX_SPEC.md` e `G2_UX_BLUEPRINT.md` definem estados/flows e critérios; `prototypes/g2-hud/index.html` é um click-through sem backend, sem combate e com dados fictícios. Não equivale a HUD real nem a teste de usabilidade concluído.

MVP exclui VIP/monetização, Diamonds, caixas/gacha, market/transações entre jogadores, social/chat/guildas, PvP, bosses compartilhados, eventos live, skills/upgrades avançados e rewards offline. Jogadores nunca compartilham espaço da hunt pessoal; qualquer social futuro usa serviços compartilhados/instanciados. Assets de jogo são PNGs autorais estáticos em lotes de dez; arte procedural não é permitida; efeitos podem ser implementados em código.

`HUD_UX_SPEC.md` define proposta desktop-first, gameplay central prioritário, equipe lateral e painéis recolhíveis em telas menores. No MVP não há chat; loja rápida não pausa combate; desconexão congela no último evento confirmado, sem reward offline. Valores/regra de bot constam no MVP Decisions. A especificação da HUD permanece design, sem implementação.

## Decisões registradas e trabalho restante

### Confirmadas diretamente pelo usuário

- x independente para cada atributo e sempre inteiro de 1–50; fator `x/10`, passos de 0,1; exemplo `4,72` rejeitado.
- Slot Arma oficial; qualquer personagem pode equipar qualquer tipo.
- **Contracorte:** 20% de chance após ataque direto de alvo único, dano físico de 50% do Ataque atual; sem recursão nem ativação por DoT.
- Baseline completo de `COMBAT_DESIGN.md` aprovado (fórmulas, armas, alvos e afinidade +5%); revisão futura só com teste/evidência registrada.
- **Stack:** Vercel + Supabase, Game Web separado do servidor.
- **Deploy confirmado:** merge em `main` do GitHub deve iniciar automaticamente um deploy de produção na Vercel, após build/checks (não literalmente instantâneo). Previews de PR são desejáveis; migrations Supabase têm fluxo separado. Integrações ainda não configuradas.
- **Sequência confirmada nesta etapa:** primeiro estruturar o projeto e revisar previews locais; deixar Vercel e Supabase (serviços externos) para uma etapa posterior. A interpretação atual de “preview” é o protótipo local de UX, não Preview Deployment Vercel.
- **Admin:** CMS no-code para tipos suportados; jogadores comuns sem acesso à aplicação/APIs; segurança server-side/RLS, auditoria e versão/rollback.
- Assets estáticos autorais em lotes de dez; sem arte procedural. HUD modular, centralidade do gameplay, desktop-first e painéis recolhíveis. Hunts pessoais não são compartilhadas; social futuro em sistemas compartilhados/instanciados.

### Baseline MVP decidido pelo agente sob delegação explícita (adaptável pelo usuário)

`MVP_DECISIONS.md` fecha objetivo, roster (Guerreiro/Arcanista/Ladino), afinidades, nível compartilhado 1–20, 10 andares, boss solo, stats e skills, catálogo/base stats de itens, nota/poder, raridades/loot, XP/Coins, consumíveis/preços, bot/revive/retorno, login convidado, desktop/PT-BR e critérios de aceite. MVP exclui VIP/pagamentos, caixas, Diamonds/market, social, PvP, bosses compartilhados, events runtime, mobile completo e progresso offline. Não atribuir essas escolhas do agente ao usuário como decisões individualmente feitas por ele.

### G2 — documentação e prova técnica parcial; gate aberto

- Baselines propostos em `G2_TECHNICAL_BLUEPRINT.md`: TypeScript/Next.js em projetos Vercel separados; Supabase; modelo de dados, contratos, rate limits iniciais, sessão Admin e lote fixo sem catch-up. Valores técnicos são propostas do agente a validar, não escolhas individualmente feitas pelo usuário.
- `PROJECT_STRUCTURE.md` propõe a organização futura dos apps, contracts, Supabase, protótipos e docs sem criar código de produção. `DEPLOYMENT_GUIDE.md` documenta o fluxo automático futuro. O usuário decidiu revisar a estrutura e o preview local primeiro; nenhuma Vercel/Supabase remota está configurada. Após a revisão, retomar os critérios técnicos G2; Vercel Preview só quando houver app seguro/buildável.
- `supabase/migrations/20260928000000_g2_core_schema.sql` cria schema-base com 17 tabelas, RLS/grants, constraints e view pública restrita ao release ativo. `supabase/tests/schema-smoke.test.mjs` aplica o SQL em PGlite; 9/9 smoke tests passaram. Isto não é validação Supabase CLI/Data API.
- `THREAT_MODEL.md` registra 20 ameaças prioritárias; somente propriedades limitadas de schema/RLS foram exercitadas no harness local, sem serviço real.
- `G2_UX_BLUEPRINT.md` define wireframes/flows/acessibilidade/plano; o usuário confirmou que abriu e validou visualmente `prototypes/g2-hud/index.html`. Não houve estudo com 5–8 testers.
- G2 continua aberto até migration testada via Supabase CLI, transações/idempotência/retry/reconexão, limites/custos, isolamento Admin/MFA, backup/restore, revisão de segurança e teste UX planejado; ver `G2_TECHNICAL_BLUEPRINT.md` e `ROADMAP.md`.
- Nenhum gameplay, Admin Web, Edge Function ou serviço foi implementado/provisionado; nenhuma integração GitHub/Vercel/Supabase foi ativada. Há somente schema-base técnico parcial e um plano documental de deploy; `game-web/` e `admin-web/` continuam inexistentes.

### Pós-MVP (backlog, não bloqueia G1/G2)

- Regras efetivas de VIP/passe/pagamentos, odds de caixas/gacha, mercado e moderação social, PvP/guildas/bosses cooperativos, eventos em runtime, stars 2–5/fusão, conteúdo adicional e localização/mobile completa só são reabertos quando fase futura for autorizada.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. `PROJECT_STRUCTURE.md` registra a proposta de organização; o preview estático local de UX em `prototypes/g2-hud/index.html` está servido na porta 4173 e retornou HTTP 200. Link-check de 15 arquivos Markdown/65 destinos relativos e `git diff --check` passaram.
2. Aguardar/recolher feedback do preview local; depois retomar as provas G2 com Supabase CLI + Docker local (`supabase start`/`db reset`), Auth/Data API e testes transacionais, de segurança/custo/backup. Não configurar serviços hospedados por enquanto. UX ainda requer 5–8 testers apesar da aprovação visual individual prévia.
3. Não criar/implantar gameplay ou Admin Web antes do gate G2. Após G2, iniciar apps e conectar Vercel/Previews quando o esqueleto estiver seguro e compilável; criar Supabase staging quando começar integração backend; reservar produção/domínio para antes do alpha fechado com checks, migrations, segurança e backup validados. A migration-base é só fundação de schema, não um jogo/backend funcional.
4. Só avançar G3/vertical slice quando os critérios G2 forem executados e o gate revisado; em cada etapa ler AI_State primeiro e fazer checkpoint mesmo se parcial.

## Histórico de etapas

### 2026-09-28 — Etapa 0: primeira documentação

- **Entregue:** README, GDD, especificação de sistemas, Roadmap e protocolo AI_State; sem features de jogo implementadas.
- **Regra processual solicitada pelo usuário:** commit e push obrigatórios no fim de todas as etapas, mesmo incompletas.
- **Checkpoint anterior:** commit `315e75f2b64bd3a28df6dd85ad7eaab440683b6a` na branch obrigatória.

### 2026-09-28 — Etapa 0: complemento de equipamentos e HUD

- **Entregue nesta atualização documental:** x individual por atributo confirmado; slot Arma e nove tipos adicionados; traços conhecidos listados com a característica da Espada pendente; arquitetura visual proposta da HUD, árvore de componentes, modelo de dados/intenções, dependências, modos/overlays, responsividade e questões pendentes.
- **Documentos afetados:** README, GDD, SYSTEMS_SPEC, novo HUD_UX_SPEC e AI_State.
- **Implementação/testes:** nenhuma implementação de gameplay ou HUD; validação documental, links internos e `git diff --check` verificados.
- **Pendências à época:** precisão de x=4,72; valores dos traços/afinidade; comportamento de auto-retorno e loja em combate; prioridade de skills; aprovação do G1.

### 2026-09-28 — Etapa 0: confirmação de x inteiro e proposta para Espada

- **Decisão confirmada:** x permanece inteiro de 1 a 50, rolado independentemente por atributo; fator de cálculo `x/10`. Exemplo fracionário `4,72` descartado.
- **Proposta registrada:** Contracorte — após receber ataque direto de alvo único, chance de contra-atacar o agressor com dano físico baseado no Ataque. Valores iniciais sugeridos para playtest: 20% de chance e 50% do Ataque atual. Sem auto-recursão nem ativação por dano ao longo do tempo.
- **Estado:** conceito e valores são recomendação, ainda aguardando aprovação e testes de balanceamento; nenhuma implementação.
- **Documentos afetados:** GDD, SYSTEMS_SPEC, HUD_UX_SPEC, Roadmap, README e este AI_State.
- **Validação:** conferidos links locais dos seis arquivos Markdown e `git diff --check`; sem testes de gameplay, pois o jogo não foi implementado.
- **Próximo passo à época:** validar/ajustar Contracorte e continuar o fechamento do design G1.

### 2026-09-28 — Etapa 1 (G1): proposta de combate e armas

- **Decisão confirmada nesta etapa:** o usuário validou Contracorte com os parâmetros documentados (20% de chance, 50% do Ataque atual, sem recursão/DoT).
- **Entregue:** `COMBAT_DESIGN.md` com fórmulas iniciais de dano, crítico, IAS/velocidade, alvo/skills automáticas, parâmetros de playtest para as demais armas e proposta de afinidade +5% no atributo ofensivo principal.
- **Documentos sincronizados:** README, GDD, SYSTEMS_SPEC, COMBAT_DESIGN, HUD_UX_SPEC, Roadmap e AI_State.
- **Estado:** checkpoint parcial da Etapa 1; as propostas das oito outras armas, afinidades e fórmulas ainda não foram validadas por playtest. Nenhuma implementação iniciada.
- **Próximo passo à época:** revisar as propostas do documento de combate e fechar decisões pendentes para aprovação de G1.

### 2026-09-28 — Etapa 1: aprovação do combate e arquitetura/plano administrativo

- **Aprovação do usuário:** todo o baseline `COMBAT_DESIGN.md`, incluindo fórmulas, parâmetros das armas e afinidade, foi aprovado; valores ainda devem ser validados em playtests futuros. Contracorte (20% / 50% Ataque) também confirmado.
- **Decisão de stack:** Vercel + Supabase, com Game Web separado do servidor/backend.
- **Requisito de produto:** painel administrativo no-code para criar/editar/publicar conteúdo suportado; isolamento de jogadores comuns e controle de acesso obrigatório em UI, servidor e banco.
- **Entregue:** `TECH_ARCHITECTURE.md` e `ADMIN_PANEL_SPEC.md`; README, GDD, SYSTEMS_SPEC, COMBAT_DESIGN, HUD_UX_SPEC, Roadmap e AI_State sincronizados. Nenhuma implementação foi iniciada.
- **Próximo passo à época:** fechar decisões restantes de G1; em seguida detalhar tecnicamente a arquitetura e segurança no G2.

### 2026-09-28 — G1: baseline de MVP e sincronização documental

- **Autorização do usuário:** o agente pode resolver decisões pendentes necessárias ao MVP; usuário poderá pedir adaptações. As escolhas de escopo foram feitas pelo agente e não são atribuídas como decisões individuais do usuário.
- **Entregue:** `MVP_DECISIONS.md` detalha produto, roster/progressão/combate/itens/loot/economia/bot, exclusões pós-MVP e critérios de aceite; incluídos vetores-base de 18 templates e estatísticas/papéis de inimigos.
- **Sincronizados:** README, GDD, SYSTEMS_SPEC, COMBAT_DESIGN, HUD_UX_SPEC, ROADMAP e AI_STATE. G1 fechado documentalmente; G2 é próxima etapa.
- **Limites:** nenhum jogo/painel/HUD foi implementado; sem playtest/balanceamento de runtime. As escolhas numéricas são baseline revisável e não indicação de prontidão.
- **Validação:** links locais em 10 arquivos Markdown e `git diff --cached --check` passaram; nenhum teste de runtime aplicável/possível sem implementação. Branch local alinhada ao remoto `2fd98d3`; checkpoint desta atualização documental ainda será commitado e enviado.

### 2026-09-28 — G2: especificação técnica, ameaça e UX (parcial)

- **Escopo seguido:** Etapa 2 do Roadmap; não implementar gameplay, Admin Web ou infraestrutura. G2 autoriza detalhamento e protótipo de UX não funcional.
- **Entregue:** `G2_TECHNICAL_BLUEPRINT.md` (dados, APIs, RLS, idempotência, simulação por lote, ambientes); `THREAT_MODEL.md` (20 ameaças e evidências); `G2_UX_BLUEPRINT.md` (wireframes/flows/a11y/plano de teste); `prototypes/g2-hud/index.html` (click-through local com dados fictícios). Specs de Tech/Admin/HUD, README, Roadmap e AI_State sincronizados.
- **Estado:** etapa parcial; nenhum serviço, migration, API, HUD ou painel criado. Sem prova técnica, testes de segurança ou teste de usabilidade com participantes; Gate G2 aberto.
- **Validação realizada:** link-check local passou em 13 Markdown; servidor estático retornou HTTP 200; parser HTML e `node --check` no JavaScript embutido passaram; `git diff --check` passou. Preview estático ficou disponível na porta 4173. Supabase CLI/Docker não estavam disponíveis; G2 seguiu parcial.

### 2026-09-28 — G2: migration-base e smoke test PostgreSQL (parcial)

- **Feedback do usuário:** conseguiu abrir o protótipo e confirmou que está tudo certo visualmente. Isso é revisão individual do click-through, não teste de usabilidade com a amostra de 5–8 pessoas do plano.
- **Escopo:** avançar G2 com uma fundação de schema autorizada pelo Roadmap, sem criar gameplay, Edge Functions, Admin Web ou provisionar serviço.
- **Entregue:** `supabase/config.toml`, migration `20260928000000_g2_core_schema.sql`, seed vazio/desabilitado e harness PGlite 0.5.8 com dependência de desenvolvimento fixada. Schema de 17 tabelas, RLS/grants, view de conteúdo ativo, segregação de seed/snapshot e constraints para rolls/equipe/sessões.
- **Teste executado:** `npm test --prefix supabase` — 9/9 passaram no PGlite 0.5.8/PostgreSQL 18.3, cobrindo aplicação do SQL, isolamento A/B, negação de escrita direta, catálogo ativo, dados privados/admin, constraints, idempotency key, append-only e cascata de exclusão de conta. `npm audit --prefix supabase` reportou zero vulnerabilidades conhecidas no harness.
- **Limites:** PGlite simula roles/Auth, executa PostgreSQL 18.3 (a config Supabase proposta mira PG15) e não é Supabase. Sem Supabase CLI/Docker, não houve teste de migration via Supabase, Auth/PostgREST, Edge Functions, Storage, transações reais de compra/combate, concorrência, RLS em serviço real, custo ou backup.
- **Estado:** G2 continua aberta; schema é fundação técnica, não backend/gameplay. Próxima prova depende de Supabase CLI + Docker ou ambiente Supabase local equivalente, e continua pendente o estudo de usabilidade com 5–8 convidados.

### 2026-09-28 — Guia de deploy automático (documentação; sem configuração externa)

- **Pedido confirmado:** explicar Supabase + Vercel passo a passo para iniciante e planejar deploy de produção automático após merge em GitHub `main`.
- **Entregue:** `docs/DEPLOYMENT_GUIDE.md`, com PR/Preview/Production, projetos/ambientes, variáveis e chaves, migrations Supabase, proteção do Admin, compatibilidade de schema e rollback. Sincronizados README, arquitetura, blueprint G2, Roadmap e AI_State.
- **Precisão de escopo:** deploy só ocorre após build/checks; Vercel e Supabase são fluxos independentes. Nenhuma integração/serviço/app foi conectado ou configurado; `game-web/` e `admin-web/` inexistem. G2 permanece aberta.
- **Validação:** link-check cobriu 14 arquivos Markdown e 60 links relativos; todos os destinos existem. `git diff --check` passou. Não houve implantação/teste em serviços externos.

### 2026-09-28 — Sequência para iniciar código e integrar serviços

- **Pergunta do usuário:** começar codificando e integrar Vercel/Supabase depois, ou incluir desde já?
- **Recomendação registrada:** integração progressiva, não deixar tudo para o final nem provisionar produção agora. Durante G2, Supabase CLI local; após G2 e com skeleton seguro/buildável, previews Vercel; staging remoto quando começar Auth/API; produção/domínio e deploy de `main` antes do alpha fechado após hardening.
- **Natureza:** recomendação de processo do agente, não escolha individualmente confirmada pelo usuário. G2 permanece aberta; nenhum código de jogo ou serviço foi criado/configurado nesta etapa.
- **Validação:** link-check cobriu 14 arquivos Markdown e 60 links relativos; todos os destinos existem. `git diff --check` passou. Nenhum app foi compilado nem serviço externo testado.

### 2026-09-28 — Estrutura local e preview antes de serviços externos

- **Direção confirmada pelo usuário:** deixar Vercel e Supabase para mais adiante; estruturar o projeto e testar previews primeiro.
- **Interpretação adotada:** neste estágio, “preview” é a prévia local estática de UX, não um Vercel Preview Deployment. Integração e serviços externos permanecem adiados; depois da revisão local, retomar testes restantes de G2.
- **Entregue:** `docs/PROJECT_STRUCTURE.md` com árvore e fronteiras propostas; atualizado guia de deploy/arquitetura/Roadmap/README. Servidor estático do protótipo existente iniciado na porta 4173; HTTP 200.
- **Limites:** não criados `game-web/`/`admin-web/`, gameplay, APIs ou novos serviços. O protótipo continua com dados fictícios e não é a aplicação.
- **Validação:** 15 arquivos Markdown e 65 links relativos verificados; todos os destinos existem. `git diff --check` passou. HTTP local do protótipo respondeu 200; sem serviços externos.
