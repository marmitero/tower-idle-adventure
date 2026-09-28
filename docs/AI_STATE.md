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
- **Fase:** Etapa 2/G2 em andamento, estritamente pré-produção. Criados blueprints técnicos/ameaças/UX e um protótipo navegável isolado, sem implementar gameplay, HUD real, Admin Web ou infraestrutura.
- **Marco atual:** G1 foi fechado documentalmente na etapa anterior. Baseline MVP continua como decisão do agente sob delegação explícita do usuário (adaptável), sem atribuir escolhas individuais ao usuário. G2 ainda requer prova técnica e avaliação de usabilidade; nenhum serviço foi provisionado e não houve teste real de segurança/infra/usuários.
- **Documentação atual:** README e doze arquivos Markdown em `docs/`; protótipo local em `prototypes/g2-hud/index.html` (dados fictícios, sem APIs/backend).
- **Validação desta etapa:** 13 arquivos Markdown passaram no link-check local; protótipo serviu HTTP 200, foi lido pelo parser HTML e passou `node --check` no JavaScript embutido; `git diff --check` passou. A sandbox não tem Supabase CLI nem Docker, então não foi possível testar migrations/RLS/transações. Nenhum teste real de segurança, infraestrutura de backend ou usabilidade foi executado.

## Resumo confiável do projeto

**Tower Idle Adventure** é um RPG idle 2D para navegador. O MVP fechado é PvE individual, desktop-first, PT-BR e alpha por convite. Conta escolhe Guerreiro, Arcanista ou Ladino, monta equipe de até três, faz hunt individual em 10 andares, ganha XP/Coins/loot e retorna ao lobby; companheiros desbloqueiam nos andares 3 e 6. Nível compartilhado vai de 1–20. Há um boss solo recorrente no andar 10. A especificação numérica completa e critérios de aceite vivem em `MVP_DECISIONS.md`.

**Status importante:** escopo baseline foi decidido pelo agente após autorização explícita do usuário. Não tratar cada valor de `MVP_DECISIONS.md` como decisão individualmente escolhida ou aprovada pelo usuário. Pode ser adaptado futuramente por solicitação. Nada foi implementado; fórmulas/valores precisam de playtest na vertical slice.

O MVP tem 10 slots (Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet), oito stats por item, seis raridades e notas/poder definidos. Regra explicitamente confirmada pelo usuário: `x` independente por atributo, inteiro de 1–50; fator `x/10`, em passos de 0,1. `x=4,72` foi rejeitado. Qualquer personagem pode equipar qualquer arma. O baseline completo de combate/armas foi aprovado pelo usuário; Contracorte tem 20% de chance após ataque direto de alvo único e causa 50% do Ataque atual, sem recursão nem ativação por DoT. Valores podem mudar com evidência de playtest.

**Stack aprovada:** Game Web e Admin Web separados na Vercel; Supabase Auth/PostgreSQL/Edge Functions/Storage no backend. Cliente não decide combate, economia ou conteúdo. Painel CMS no-code fica isolado; jogadores comuns não veem sua interface nem acessam APIs administrativas. Especificações em `TECH_ARCHITECTURE.md`, `ADMIN_PANEL_SPEC.md`, `G2_TECHNICAL_BLUEPRINT.md` e `THREAT_MODEL.md`; nada foi provisionado/implementado.

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
- **Admin:** CMS no-code para tipos suportados; jogadores comuns sem acesso à aplicação/APIs; segurança server-side/RLS, auditoria e versão/rollback.
- Assets estáticos autorais em lotes de dez; sem arte procedural. HUD modular, centralidade do gameplay, desktop-first e painéis recolhíveis. Hunts pessoais não são compartilhadas; social futuro em sistemas compartilhados/instanciados.

### Baseline MVP decidido pelo agente sob delegação explícita (adaptável pelo usuário)

`MVP_DECISIONS.md` fecha objetivo, roster (Guerreiro/Arcanista/Ladino), afinidades, nível compartilhado 1–20, 10 andares, boss solo, stats e skills, catálogo/base stats de itens, nota/poder, raridades/loot, XP/Coins, consumíveis/preços, bot/revive/retorno, login convidado, desktop/PT-BR e critérios de aceite. MVP exclui VIP/pagamentos, caixas, Diamonds/market, social, PvP, bosses compartilhados, events runtime, mobile completo e progresso offline. Não atribuir essas escolhas do agente ao usuário como decisões individualmente feitas por ele.

### G2 — documentação-base entregue; gate aberto

- Baselines propostos em `G2_TECHNICAL_BLUEPRINT.md`: TypeScript/Next.js em projetos Vercel separados; Supabase; modelo de dados MVP, endpoints, revisões/idempotência, RLS/grants, rate limits iniciais, sessão Admin e lote de simulação fixo sem catch-up. Valores técnicos são propostas do agente a validar, não escolhas individualmente feitas pelo usuário.
- `THREAT_MODEL.md` registra atores/fronteiras, 20 ameaças prioritárias, mitigações e evidências necessárias; nenhum controle foi testado em ambiente real.
- `G2_UX_BLUEPRINT.md` define wireframes, fluxos, estados, acessibilidade e plano de teste. `prototypes/g2-hud/index.html` é protótipo somente local/fictício.
- G2 continua aberto até prova local de migrations/RLS/transações/retry/reconexão, revisão de custo/backup, testes de isolamento admin e teste de usabilidade com 5–8 testers; conferir critérios em `G2_TECHNICAL_BLUEPRINT.md` e `ROADMAP.md`.
- Nenhum gameplay, Admin Web ou serviço foi implementado/provisionado nesta atualização.

### Pós-MVP (backlog, não bloqueia G1/G2)

- Regras efetivas de VIP/passe/pagamentos, odds de caixas/gacha, mercado e moderação social, PvP/guildas/bosses cooperativos, eventos em runtime, stars 2–5/fusão, conteúdo adicional e localização/mobile completa só são reabertos quando fase futura for autorizada.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. Checagens documentais concluídas: links locais, consistência cruzada, smoke test estático (HTTP 200, parse HTML e sintaxe JS) e `git diff --check`; o checkpoint desta atualização preserva o estado parcial.
2. G2 permanece aberta. A próxima fatia precisa de toolchain Supabase CLI + Docker disponível para testar migrations/RLS/grants/transações/idempotência/desconexão-reconexão; depois, avaliação UX com 5–8 testers e revisão de segurança/custo/backup. Esta sandbox não tem CLI nem Docker.
3. Não implementar gameplay ou Admin Web nesta etapa sem o gate; especificações e click-through não significam que funcionalidades estejam prontas.
4. Só avançar a G3/vertical slice quando os critérios G2 forem executados e o gate revisado; em cada etapa ler AI_State primeiro e fazer checkpoint mesmo se parcial.

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
- **Validação realizada:** link-check local passou em 13 Markdown; servidor estático retornou HTTP 200; parser HTML e `node --check` no JavaScript embutido passaram; `git diff --check` passou. Preview estático ficou disponível na porta 4173. Supabase CLI/Docker não estão disponíveis; nenhuma prova backend ou de segurança foi executada, então G2 segue parcial.
