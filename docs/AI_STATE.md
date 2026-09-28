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
- **Fase:** Etapa 1 — fechamento de escopo e design (G1), em andamento.
- **Marco atual:** baseline completo de combate aprovado; direção Vercel + Supabase e requisito do Painel Administrativo aprovados e documentados. G1 continua em andamento por decisões restantes de roster, progressão, economia e MVP. Nenhuma implementação iniciada.
- **Estado inicial do repositório:** somente `README.md` inicial; sem código de jogo e sem AI_State prévio.
- **Documentação atual:** README e oito arquivos em `docs/`: GDD, sistemas, combate, HUD/UX, arquitetura técnica, painel administrativo, Roadmap e este AI_State.
- **Validação:** nenhuma execução de jogo; 9 arquivos Markdown e links locais verificados, `git diff --check` passou. O baseline de combate ainda precisa ser medido em playtests.

## Resumo confiável do projeto

RPG idle 2D para navegador, **Tower Idle Adventure**. Jogador prepara até três personagens no lobby, escolhe manualmente um andar e deixa a equipe lutar automaticamente contra encontros de 1–3 inimigos. Vitórias encadeiam novas lutas e dão XP/moedas/loot. Derrota retorna ao lobby, onde a equipe cura gratuitamente. Autoavançar andares é um recurso VIP opcional. Conta VIP também tem passe/recompensas diárias, +30% XP e +15% farm. Social e atividades compartilhadas (chat, guilda, amigos, PvP, market e bosses) não colocam jogadores no espaço pessoal de hunt.

A equipe usa dez slots: **Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet**. Todo item possui Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, Chance Crítica, Velocidade de Ataque e Velocidade. Multiplicadores de raridade: Comum 1,0; Incomum 1,2; Raro 1,5; Épico 2,0; Lendário 2,5; Celestial 3,0. Fórmula base: `valorFinal = base × multiplicadorRaridade × (x/10)`. **Confirmado pelo usuário: x é rolado aleatoriamente e independentemente para cada atributo do equipamento, sempre como inteiro de 1–50.** O fator aplicado é `x/10`, de 0,1x a 5,0x em passos de 0,1; `x=37` significa fator `×3,7`. O exemplo `x=4,72` foi descartado: nenhum x fracionário é permitido. Lendário/Celestial podem ter uma característica aleatória extra independente da raridade/x.

Armas podem ser equipadas por qualquer personagem; afinidades nunca restringem o uso. Os traços dos nove tipos e o bônus de afinidade estão aprovados como baseline v0.1 em `COMBAT_DESIGN.md`; Contracorte foi validado com 20% de chance e 50% do Ataque após ataque direto de alvo único. O documento define dano, crítico, Velocidade/IAS, alvos, automação, os outros oito traços e afinidade de +5% ao atributo ofensivo principal. Valores podem ser revisitados com evidências de playtest. Traço de tipo é separado da característica aleatória adicional Lendária/Celestial. Arma `Luvas` não é a armadura do slot `Luva`.

`COMBAT_DESIGN.md` propõe fórmula de mitigação `PoderOfensivo × coeficiente × 100/(100+Defesa)`, crítico de 1,5× com teto de 75%, Velocidade para ordem inicial e IAS para intervalo, alvos automáticos, skills por ordem de slot, traços numéricos e afinidade +5% ao atributo ofensivo principal. Esse baseline foi aprovado pelo usuário; validação de runtime/playtest ainda não ocorreu.

**Arquitetura aprovada:** Vercel hospeda Game Web e Admin Web separados; Supabase é o servidor/backend (Auth, PostgreSQL, Edge Functions e Storage; Realtime conforme necessidade). O navegador não é autoridade do jogo. O painel no-code de conteúdo será deployment separado, sem link na experiência de jogadores, com roles autorizadas, validação server-side/RLS, auditoria e publicação versionada. Detalhes em `TECH_ARCHITECTURE.md` e `ADMIN_PANEL_SPEC.md`.

A HUD desktop proposta mantém perfil no topo esquerdo, equipe abaixo, navegação superior central, automação no topo direito, gameplay no centro, log inferior, chat compacto embaixo à direita e overlays/painéis secundários. O documento `docs/HUD_UX_SPEC.md` descreve componentes, fluxo de dados, estados e dependências. O jogador configura poções/revives e pode ligar/desligar cada skill equipada na automação; prioridade de skills pode vir depois. A HUD também pede opção de retorno após derrota; regra exata (curar no lobby e reiniciar mesmo andar?) segue pendente. Loja rápida mantém contexto de batalha; pausa/continuação da batalha ao abrir a loja requer confirmação. Não assumir recompensas offline.

## Decisões registradas e pendências

### Confirmadas

- x independente por atributo e sempre inteiro de 1–50; fator `x/10` em passos de 0,1; x fracionário como `4,72` não é permitido.
- Slot Arma oficial; qualquer personagem pode usar qualquer arma.
- **Contracorte validado:** 20% de chance, dano de 50% do Ataque após ataque direto de alvo único; sem recursão/DoT.
- **Baseline completo de `COMBAT_DESIGN.md` aprovado:** fórmulas de dano/crítico/velocidade, alvos e automação, traços de todas as armas e afinidade de +5%; ajuste futuro somente com teste/registro.
- **Stack aprovada:** Vercel para Game Web/Admin Web em deployments separados; Supabase como backend/servidor.
- **Painel Administrativo aprovado:** CMS no-code para conteúdo suportado; usuários comuns não veem nem acessam painel/APIs; autorização server-side, RLS, auditoria e publicação versionada.
- HUD documentada antes da implementação; protocolo de checkpoint exige commit e push ao fim de toda etapa, mesmo parcial.

### A resolver antes de G1

1. Roster inicial/classes, distribuição de afinidades, skills e regras finais de slots/progressão.
2. Nota/poder de itens/equipe: escala, pesos, normalização de percentuais e influência de características.
3. Default e regra do toggle “voltar após derrota”, cura/reentrada e se a loja pausa combate.
4. Bases por slot/nível, progressão/XP/materiais, valores de consumíveis, odds/preços das caixas e definição do bônus de farm.
5. Escopo de simulação offline, resumo da sessão e retenção de eventos.
6. Arena/PvP, market/fees/diamantes, bosses e escopo do MVP.
7. Arte final, responsividade/suporte mobile e idiomas.
8. Conformidade, privacidade, pagamentos e plano de moderação.

### Para G2 — pré-produção técnica

- Refinar a arquitetura escolhida, limites/jobs/Edge Functions, schemas/migrations, RLS, MFA, backup, threat model, cache/versionamento e custos.
- Implementação e teste de isolamento do painel, provisioning do Owner e RBAC; detalhes em `ADMIN_PANEL_SPEC.md`.
- Nenhuma dessas decisões deve ser inventada silenciosamente no código.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. Fechar as decisões restantes de G1 (roster, progressão, economia, offline, MVP) sem reabrir o baseline de combate aprovado, exceto por evidência de playtest.
2. Em G2, detalhar e validar tecnicamente a arquitetura Vercel + Supabase e a segurança/fluxo do painel administrativo.
3. Somente após os gates de design/pré-produção, começar a vertical slice; antes da HUD, revisar estados/dependências documentados.
4. Em cada checkpoint, atualizar este estado, rodar validações aplicáveis e fazer commit + push mesmo se a etapa estiver parcial.

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
- **Próximo passo:** fechar decisões restantes de G1; em seguida detalhar tecnicamente a arquitetura e segurança no G2.
