# AI_State — handoff vivo do Tower Idle Adventure

**Objetivo:** este documento é a passagem de contexto para qualquer pessoa/agente que continue o projeto sem acesso a conversas anteriores. Leia-o primeiro em cada etapa; depois consulte os documentos-fonte indicados abaixo. As afirmações sobre plataformas externas são identificadas como relato do usuário quando não foram verificadas diretamente no Dashboard.

**Última atualização documental:** 2026-09-28. **Marco atual:** G2 (pré-produção técnica, segurança e UX) em andamento; não avançar para gameplay/vertical slice antes do gate G2.

**Checkout da sessão:** `/home/user/tower-idle-adventure` · **remote:** `origin` → `marmitero/tower-idle-adventure` · **branch obrigatória:** `arena/01a0e5e1-tower-idle-adventure`.

## 1. Regras obrigatórias para quem continuar

1. No início: ler este arquivo, conferir `git status`, branch e `git log`; depois abrir os documentos-fonte relevantes. Não presumir que uma anotação antiga prevalece sobre o estado mais recente.
2. Trabalhar sempre na branch `arena/01a0e5e1-tower-idle-adventure`. **Nunca trocar de branch, criar outra branch para esta sessão, nem enviar alterações para outra branch.** O repositório canônico deste checkout é `marmitero/tower-idle-adventure`.
3. Ao final de toda etapa, mesmo parcial/pausada: atualizar este AI_State e os documentos afetados; executar verificações pertinentes; criar commit e fazer push somente para `origin arena/01a0e5e1-tower-idle-adventure`; confirmar sucesso e informar o hash. Não deixar trabalho concluído sem checkpoint.
4. Não afirmar que algo foi testado, implantado, aprovado ou configurado em um serviço externo sem evidência. Separar sempre **estado verificado no repositório**, **relato do usuário** e **proposta/recomendação**.
5. O usuário prefere fluxo browser-first para GitHub, Supabase e Vercel e não quer instalar CLI, Docker ou outras ferramentas no próprio computador. O agente deve fazer primeiro tudo que for possível no repositório e pelas integrações disponíveis; só pedir ajuda ao usuário para login/OAuth/consentimento, ações que exijam Dashboard autenticado, permissões, billing ou algo que o agente não possa acessar. Nunca solicitar senha, token, service-role key, código MFA ou outro segredo; ensinar o clique necessário pelo navegador e pedir apenas confirmação/dados não secretos.
6. O usuário pediu que o agente implemente o máximo possível e ensine apenas as partes que não consegue executar. Isso **não** autoriza pular o gate G2, publicar em produção, fazer merge em `main` sem revisão, nem apresentar apps/recursos não construídos como prontos.
7. Documentação/design precedem implementação de produto. O baseline do MVP foi escolhido pelo agente sob delegação explícita do usuário; não atribuir cada valor a uma escolha individual do usuário, e manter valores adaptáveis quando ele pedir.
8. Automatic Preview/Preview Branch do Supabase está deliberadamente desligado no plano atual. Não recomendar upgrade nem fluxos que dependam dele sem nova decisão do usuário. Sem preview DB por PR, migrations devem ser revisadas antes do merge e verificadas no projeto dev compartilhado depois.

## 2. O projeto em uma visão

**Tower Idle Adventure** é um RPG idle automático 2D para navegador, centrado em uma torre, progressão de equipe, equipamentos e batalhas PvE automáticas. O MVP é individual, desktop-first e PT-BR; o jogo não está implementado. A conta escolhe um personagem, monta uma equipe de até três, faz hunts pessoais por andares, ganha XP/Coins/loot e retorna ao lobby. Detalhes de produto, números e critérios de aceite estão em [`MVP_DECISIONS.md`](MVP_DECISIONS.md), [`GDD.md`](GDD.md) e [`SYSTEMS_SPEC.md`](SYSTEMS_SPEC.md).

O projeto encontra-se em **pré-produção**: especificações, threat model, protótipo UX estático, fundação SQL e inventário de arte existem; não há gameplay, backend funcional, app Game Web, Admin Web, deployment Vercel ou validação Supabase hospedada confirmada. O projeto Supabase dev e sua configuração GitHub são relatados pelo usuário, conforme §4.

## 3. Produto, decisões e limites de escopo

### Decisões confirmadas diretamente pelo usuário

- Stack escolhida: **Supabase + Vercel**. Game Web é separado do servidor/backend; Admin Web/CMS será app separado, acessível apenas a administradores autorizados.
- O usuário aprovou o baseline completo de combate/armas em [`COMBAT_DESIGN.md`](COMBAT_DESIGN.md). **Contracorte:** 20% de chance após ataque direto de alvo único; causa 50% do Ataque atual; sem recursão e sem ativação por DoT.
- Equipamento: multiplicador `x` independente por atributo, inteiro de 1–50; fator `x/10`, em incrementos de 0,1. `x=4,72` foi rejeitado. Slot Arma existe e qualquer personagem pode equipar qualquer tipo de arma.
- Usar o pack de sprites já existente como base e adicionar/criar arte depois; não usar arte procedural. Preservar créditos/licenças e seguir a leitura conservadora dos avisos do pack até qualquer conflito de licença ser esclarecido.
- HUD modular, desktop-first; hunts pessoais não são compartilhadas. Recursos sociais compartilhados/instanciados são pós-MVP.
- Evitar instalações locais e usar navegador para configuração das plataformas. Agent-first para o trabalho: agente implementa o que for acessível; usuário só é acionado para autorização/ações de Dashboard inacessíveis.
- Merge em GitHub `main` deve, futuramente, disparar deploy de produção Vercel após build/checks. Vercel ainda não foi conectada e não existe app para deploy.
- Automatic Preview/Preview Branch no Supabase fica **desligado**: o usuário informou que requer plano Pro e prefere não habilitar/pagar por isso.

### Baseline MVP delegado ao agente (adaptável; ver fonte canônica)

O usuário autorizou o agente a resolver decisões abertas necessárias para fechar o MVP. O agente registrou o baseline em [`MVP_DECISIONS.md`](MVP_DECISIONS.md); não trate todos os números como se o usuário os tivesse escolhido individualmente. Resumo: classes Guerreiro/Arcanista/Ladino; nível compartilhado 1–20; equipe até três; 10 andares e boss solo no andar 10; slots Arma, Peitoral, Elmo, Calça, Bota, Luva, Colar, Aura, Asa e Pet; 8 stats por item; seis raridades; loot/economia, consumíveis e bot descritos no documento. O baseline não foi validado em playtest e pode ser ajustado por pedido/evidência.

**Fora do MVP:** VIP/monetização, Diamonds, caixas/gacha, market/transações entre jogadores, PvP, chat/guildas, bosses compartilhados, eventos live, sistemas avançados de skills/upgrades e rewards/progresso offline. Hunts pessoais são privadas.

## 4. Estado de plataformas e deploy

### Supabase — estado reportado pelo usuário em 2026-09-28

O usuário forneceu os seguintes dados da configuração no Dashboard. **O agente não teve acesso autenticado ao Dashboard e não verificou visualmente esses valores; registre-os como informados pelo usuário, não como teste independente.**

- Projeto de desenvolvimento criado: **`tower-idle-adventure-dev`**.
- Repositório GitHub conectado: **`marmitero/tower-idle-adventure`** (confere com o remote deste checkout; a divergência de nome mencionada antes foi resolvida pelo usuário).
- **Working directory:** `.` (raiz do repositório; `supabase/` está na raiz).
- **Deploy to production:** ativado para essa integração/projeto Supabase dev.
- **Production branch name:** usuário informou **`Main`**. A branch do repositório foi referida como `main`; como nomes de refs Git são sensíveis a maiúsculas/minúsculas, confirmar no Dashboard que o valor selecionado é exatamente a branch existente (`main`) se houver dúvida. O rótulo “production” nesse contexto da integração Supabase é a branch/projeto-base configurado, não significa que o banco público de produção do jogo foi criado.
- **Automatic Preview/Automatic Branching/Preview Branch:** desligado, pois o usuário informou que a função exige plano Pro e deseja deixá-la desligada. Não há banco isolado automático para cada PR.
- **Migration:** ainda não há confirmação de que `20260928000000_g2_core_schema.sql` foi aplicada ao projeto nem de que seu resultado foi inspecionado. O toggle ligado indica a intenção de aplicar mudanças da branch conectada ao projeto-base, mas só o histórico/status do Dashboard confirma a aplicação real.
- Usar apenas dados sintéticos. Não conectar um eventual Supabase de produção a este fluxo; nenhum setup de produção foi reportado/verificado.

**Consequência operacional:** após revisar um PR e integrar as alterações à branch correta `main`, a integração Supabase configurada para o projeto dev deve atualizar **o projeto dev**, se o repo/branch estão corretos e a migração é válida. Como Preview Branch está desligada, não há validação SQL em DB efêmero antes do merge. Revisar migration no PR e depois checar histórico de migrations/schema no Supabase Dashboard. Não dizer que migration está aplicada até haver essa evidência.

### Vercel — estado reportado pelo usuário

- **Ainda não integrada ao GitHub; nenhum projeto Vercel foi criado.** O usuário confirmou que ainda não fez configuração na Vercel.
- `apps/game-web/` e `apps/admin-web/` não existem; não há app para importar ou deployment de produção. Não inventar URLs, domínios, project IDs, build settings ou sucesso de deploy.
- Futuro previsto: dois projetos Vercel independentes, Root Directory `apps/game-web/` e `apps/admin-web/`; Production Branch `main`; Preview por PR e Production após merge/checks. Configurar ambientes/secrets com Supabase dev em Preview e produção separada só depois dos gates.

### GitHub e limites de acesso

- Remote do repositório nesta sessão: `https://github.com/marmitero/tower-idle-adventure.git`.
- O agente pode editar arquivos, executar verificações disponíveis no ambiente, fazer commit/push na branch fixa e usar integrações GitHub autorizadas (por exemplo, abrir PR/consultar checks quando as permissões permitirem). Repositório/configurações protegidas podem exigir permissão externa.
- Não existe acesso confirmado do agente às sessões autenticadas dos Dashboards Supabase/Vercel. O usuário pode fornecer estado/status/screenshot sem segredos; não pedir credenciais.
- A orientação antiga que exigia instalar Supabase CLI/Docker/Vercel CLI para começar foi superada. Comandos podem ser usados no ambiente do agente quando forem úteis/disponíveis, sem exigir instalação no computador do usuário.

## 5. Estado real do código e evidências

### Artefatos presentes

- [`prototypes/g2-hud/index.html`](../prototypes/g2-hud/index.html): click-through estático, sem backend/gameplay e com dados fictícios; sheets `hero`, `mage`, `slime` são candidatos provisórios, não arte/mapeamento aprovados nem HUD de produção. O usuário já confirmou uma revisão visual individual; isso não substitui estudo com participantes.
- [`supabase/migrations/20260928000000_g2_core_schema.sql`](../supabase/migrations/20260928000000_g2_core_schema.sql): migration-base/fundação de schema, não implementação do jogo.
- [`supabase/tests/schema-smoke.test.mjs`](../supabase/tests/schema-smoke.test.mjs): 9 smoke tests PGlite. Histórico: `npm test --prefix supabase` passou 9/9 usando PGlite 0.5.8/PostgreSQL 18.3; `npm audit --prefix supabase` reportou 0 vulnerabilidades conhecidas no harness. `supabase/config.toml` propõe PostgreSQL 15; há diferença de major version em relação ao PGlite usado.
- Schema atual documentado com 17 tabelas, RLS/`FORCE ROW LEVEL SECURITY`, grants e constraints. Seed `supabase/seed.sql` está vazio/desabilitado. Não há Edge Functions, endpoints de jogo/Admin, fluxo Auth implementado, transações econômicas, loop de batalha ou catálogo publicado.
- [`sprites/`](../sprites/) contém o pack inicial Fantasy Dungeon de Nika Studio; manifesto [`sprites/ASSET_MANIFEST.md`](../sprites/ASSET_MANIFEST.md) registra 422 PNGs válidos, créditos e limitações. Usar subset aprovado; não empacotar o pack inteiro por padrão. Créditos/licença em `sprites/LICENSE.txt` e `sprites/README_IMPORT.txt` devem ser preservados.

### O que NÃO está implementado/confirmado

- Nenhum Game Web ou Admin Web em `apps/`; nenhum deployment Vercel.
- Nenhum fluxo de gameplay, cliente autoritativo, Edge Function, Auth, Storage, API, CMS ou transação de economia.
- A migration-base não foi confirmada como aplicada/testada em Supabase real; PGlite não testa Supabase Auth, PostgREST/Data API, Edge Functions, Storage, concorrência real, custos, backup ou configuração do provedor.
- Nenhum preview Supabase por PR; nenhum teste de migration hospedado confirmado. Supabase dev/configuração GitHub são relato do usuário, não observação autenticada do agente.
- Não há teste de segurança/backup/restore em ambiente real, nem estudo UX com os 5–8 participantes planejados.
- Nenhum app foi implantado, nenhum domínio final foi escolhido, e nenhuma produção Supabase/Vercel foi liberada.

## 6. Gate G2: o que falta para encerrar

Ver critérios completos em [`ROADMAP.md`](ROADMAP.md), [`G2_TECHNICAL_BLUEPRINT.md`](G2_TECHNICAL_BLUEPRINT.md), [`THREAT_MODEL.md`](THREAT_MODEL.md) e [`G2_UX_BLUEPRINT.md`](G2_UX_BLUEPRINT.md). Mínimos pendentes:

1. Confirmar no Dashboard que a branch de produção do **Supabase dev** coincide com a ref GitHub `main`; verificar status/histórico e schema da migration-base após execução em dev. Não interpretar `Deploy to production` como Vercel ou como banco real de produção.
2. Validar Auth, Data API/PostgREST, grants/RLS com usuários/roles representativos; registrar resultados reais.
3. Projetar/testar transações, idempotência/replay, concorrência, reconexão e regras de segurança do servidor para ações de jogo. O cliente nunca decide combate, moeda, drops ou autorização.
4. Definir/validar limites de Edge Functions, rate limiting, latência/custos, observabilidade, backups e restore. Não afirmar backup ativo antes de testar restauração.
5. Fechar threat model e isolamento real de Admin/MFA antes de qualquer Admin acessível.
6. Executar plano de usabilidade com 5–8 convidados; revisão visual individual do protótipo não basta.
7. Confirmar planos/custos e manter produção isolada até os checks e aprovações apropriados.

Não usar a ausência de Preview Branch como motivo para instalar ferramentas ou pagar plano Pro. A validação browser-only neste estágio é no projeto dev compartilhado depois de merge revisado. Se for necessária uma prova antes de `main`, avaliar um segundo Supabase dev persistente ou GitHub Actions hospedado, sem assumir disponibilidade/custo nem habilitar sem decisão.

## 7. Próximo fluxo recomendado para a IA sucessora

1. Ler novamente este AI_State; conferir branch, `git status`, `git log` e estado do remote. Continuar exclusivamente em `arena/01a0e5e1-tower-idle-adventure`.
2. Não pedir novamente os dados já informados: Supabase `tower-idle-adventure-dev`, repo `marmitero/tower-idle-adventure`, Working Directory `.`, Deploy to production ON, Production branch `Main`, Automatic Preview OFF, Vercel sem integração/projeto. Em documentos futuros, preservar a ressalva de que são valores reportados pelo usuário, não verificados pelo agente. Pendências reais: confirmar se `Main` é exatamente a ref GitHub `main` e consultar no Dashboard se a migration-base já foi aplicada.
3. Como tarefa repo-side de baixo risco, inspecionar se há workflow GitHub Actions; o checkout atual não tem `.github/`. Se continuar útil ao G2, propor/implementar workflow hospedado para executar `npm test --prefix supabase` (e eventualmente audit) em PRs. Isso não requer instalação no computador do usuário e não substitui teste Supabase.
4. Não fazer merge automático em `main` nem provocar execução de migrations em ambiente externo sem revisar o PR/diff, verificar destino dev e obter aprovação humana apropriada. Deploy to production está ligado no Supabase dev reportado; o merge pode alterar esse banco compartilhado.
5. Para aplicação real da migration, pedir ao usuário somente uma confirmação não secreta do Dashboard (migration status/schema ou screenshot com chaves ocultas); nunca pedir project password, access token, service-role key ou credenciais.
6. Depois do gate G2, e só então, iniciar a vertical slice G3 conforme `ROADMAP.md`; implementar Game Web/Admin Web com limites de segurança documentados. Quando apps existirem, ajudar a configurar Vercel pelo navegador, pois o agente não tem sessão autenticada de Vercel.
7. Ao final da etapa, sincronizar AI_State e os docs que mudaram, executar testes/document checks, commitar e dar push para a branch fixa, registrar hash no retorno.

## 8. Mapa de documentos-fonte

- [`README.md`](../README.md): resumo do estado e navegação.
- [`GDD.md`](GDD.md), [`SYSTEMS_SPEC.md`](SYSTEMS_SPEC.md), [`MVP_DECISIONS.md`](MVP_DECISIONS.md): visão, regras de produto e baseline MVP (decisões do agente sob delegação destacadas).
- [`COMBAT_DESIGN.md`](COMBAT_DESIGN.md): fórmulas/armas/afinidades e decisões aprovadas.
- [`HUD_UX_SPEC.md`](HUD_UX_SPEC.md), [`G2_UX_BLUEPRINT.md`](G2_UX_BLUEPRINT.md), `../prototypes/g2-hud/index.html`: UX e protótipo não funcional.
- [`TECH_ARCHITECTURE.md`](TECH_ARCHITECTURE.md), [`G2_TECHNICAL_BLUEPRINT.md`](G2_TECHNICAL_BLUEPRINT.md), [`THREAT_MODEL.md`](THREAT_MODEL.md), [`ADMIN_PANEL_SPEC.md`](ADMIN_PANEL_SPEC.md): arquitetura, segurança, G2 e Admin.
- [`DEPLOYMENT_GUIDE.md`](DEPLOYMENT_GUIDE.md), [`PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md), [`ROADMAP.md`](ROADMAP.md): deploy browser-first, estrutura futura e gates.
- [`../supabase/README.md`](../supabase/README.md), migration e tests: escopo SQL, limites do harness e validações.
- [`../sprites/ASSET_MANIFEST.md`](../sprites/ASSET_MANIFEST.md): inventário e créditos do pack.

## 9. Histórico resumido e instruções superadas

- G0/G1 foram fechados documentalmente; G2 foi aberta para arquitetura, segurança, pipeline de arte e UX, sem gameplay de produção.
- G2 produziu blueprints, threat model, click-through estático, migration-base e harness PGlite. É trabalho parcial; nenhum desses artefatos por si fecha G2 ou representa jogo/back-end pronto.
- O usuário abriu/revisou visualmente o protótipo e autorizou o início do onboarding Supabase/Vercel. Depois especificou o fluxo browser-only e que Automatic Preview exige Pro e deve continuar desligado.
- A recomendação antiga de instalar CLI/Docker para validação local está **superada**. A recomendação anterior de habilitar Preview Branch também está **superada**.
- Snapshot anterior sincronizado antes desta revisão: commit `5705d14` na branch desta sessão; consulte `git log` para o hash atual após este checkpoint.
