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
- **Fase:** Etapa 1/G1 concluída documentalmente; G2 é o próximo marco. Esta atualização continua sendo trabalho documental e não implementa gameplay/painel.
- **Marco atual:** baseline de escopo MVP registrado em `MVP_DECISIONS.md` sob autorização explícita do usuário para o agente decidir pendências. As escolhas do agente não são atribuídas como decisões individuais do usuário. MVP ainda sem implementação/playtest. Arquitetura-base Supabase + Vercel e Admin CMS estão documentadas, não provisionadas.
- **Documentação atual:** README e nove arquivos Markdown em `docs/`, incluindo o novo `MVP_DECISIONS.md`.
- **Validação desta etapa:** revisão documental concluída; links locais em 10 Markdown e `git diff --cached --check` passaram. Nenhum jogo/teste de runtime existe. Branch sincronizada com o remoto antes das alterações; commit e push desta etapa ainda pendentes.

## Resumo confiável do projeto

**Tower Idle Adventure** é um RPG idle 2D para navegador. O MVP fechado é PvE individual, desktop-first, PT-BR e alpha por convite. Conta escolhe Guerreiro, Arcanista ou Ladino, monta equipe de até três, faz hunt individual em 10 andares, ganha XP/Coins/loot e retorna ao lobby; companheiros desbloqueiam nos andares 3 e 6. Nível compartilhado vai de 1–20. Há um boss solo recorrente no andar 10. A especificação numérica completa e critérios de aceite vivem em `MVP_DECISIONS.md`.

**Status importante:** escopo baseline foi decidido pelo agente após autorização explícita do usuário. Não tratar cada valor de `MVP_DECISIONS.md` como decisão individualmente escolhida ou aprovada pelo usuário. Pode ser adaptado futuramente por solicitação. Nada foi implementado; fórmulas/valores precisam de playtest na vertical slice.

O MVP tem 10 slots (Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet), oito stats por item, seis raridades e notas/poder definidos. Regra explicitamente confirmada pelo usuário: `x` independente por atributo, inteiro de 1–50; fator `x/10`, em passos de 0,1. `x=4,72` foi rejeitado. Qualquer personagem pode equipar qualquer arma. O baseline completo de combate/armas foi aprovado pelo usuário; Contracorte tem 20% de chance após ataque direto de alvo único e causa 50% do Ataque atual, sem recursão nem ativação por DoT. Valores podem mudar com evidência de playtest.

**Stack aprovada:** Game Web e Admin Web separados na Vercel; Supabase Auth/PostgreSQL/Edge Functions/Storage no backend. Cliente não decide combate, economia ou conteúdo. Painel CMS no-code de conteúdo fica isolado; jogadores comuns não veem sua interface nem acessam APIs administrativas. Docs de arquitetura e segurança estão em `TECH_ARCHITECTURE.md` e `ADMIN_PANEL_SPEC.md`; nada foi provisionado/implementado.

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

### Para G2 — pré-produção técnica/UX

- Refinar arquitetura em schemas/migrações, contratos API/eventos, autoridade do simulador, RLS, roles/MFA, threat model, rate limits, backup/recuperação, cache/versionamento e custos.
- Fechar desenho/protótipo UX e detalhar provisioning/isolamento do Owner/Admin; implementar e testar segurança só nos marcos autorizados do Roadmap.
- Definir instrumentação/QA e pipeline de assets, sem iniciar gameplay na etapa documental atual.

### Pós-MVP (backlog, não bloqueia G1/G2)

- Regras efetivas de VIP/passe/pagamentos, odds de caixas/gacha, mercado e moderação social, PvP/guildas/bosses cooperativos, eventos em runtime, stars 2–5/fusão, conteúdo adicional e localização/mobile completa só são reabertos quando fase futura for autorizada.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. Conferir diffs/Git status e revisar consistência do MVP com GDD, Sistemas, Combate, HUD, Roadmap e arquitetura; validar links Markdown e `git diff --check`.
2. Registrar atualização final do AI_State; criar commit e push na branch obrigatória e confirmar hash.
3. Próxima etapa: G2 — schemas/API, threat model, isolamento/Admin, UX/protótipo e planejamento técnico. Não implementar gameplay ou painel antes dos gates G2/G3 no Roadmap.
4. Em cada checkpoint, ler AI_State no início, atualizar documentos e fazer commit + push mesmo que a etapa termine parcial.

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
