# Roadmap — Tower Idle Adventure

**Versão:** 0.1 — plano macro
**Status atual:** Etapa 0 concluída no escopo da documentação inicial; documentação entregue para revisão, G1 ainda pendente e nenhum produto implementado.
**Princípio:** cada etapa começa lendo [AI_State](AI_STATE.md), altera a documentação antes do código quando houver decisão de design e termina atualizando AI_State e evidências.

## Marcos de aprovação

- **G0 — visão documentada:** visão, requisitos e riscos registrados (documentação inicial entregue; aguarda revisão).
- **G1 — design aprovado:** decisões de gameplay/economia, MVP, critérios de aceite e escopo assinados antes de implementar.
- **G2 — pré-produção pronta:** arquitetura, pipeline de arte, privacidade/segurança e protótipo de UX aprovados.
- **G3 — vertical slice validada:** loop curto jogável com qualidade visual/técnica e métricas de diversão/legibilidade validadas.
- **G4 — alpha de conteúdo:** sistemas do MVP e conteúdo suficiente integrados, testes de estabilidade em andamento.
- **G5 — beta/soft launch:** serviço operável, economia e moderação verificadas em escala controlada, suporte preparado.
- **G6 — lançamento:** publicação, monitoramento e plano de resposta ativos.

Não avançar de marco por calendário apenas; cada gate depende de critérios de aceite e riscos resolvidos.

## Etapas de produção

### Etapa 0 — Descoberta e documentação inicial (concluída)

- Consolidar o briefing e registrar visão, pilares, regras fornecidas, fórmulas e ambiguidades.
- Criar AI_State, documentação principal e caminho de produção.
- **Saída:** GDD v0.1, especificação de sistemas v0.1, arquitetura proposta da HUD/UX v0.1, roadmap v0.1, AI_State atualizado.
- **Critério:** requisitos rastreáveis; nenhum código apresentado como jogo pronto.
- **Situação:** concluída nesta entrega como primeira versão, aguardando revisão/decisões para fechar G0.

### Etapa 1 — Fechamento de escopo e design (G1)

- Resolver decisões prioritárias: roster/classe, precisão decimal/discreta do x (x individual por atributo já confirmado), traços e afinidades das armas (traço de Espada ainda pendente), fórmula de combate, atributos-base por slot/nível, nota/poder, loot odds e preços, regras de revive/retorno após derrota/estrelas, VIP, offline, market e PvP.
- Definir experiência de onboarding, wireframes, condições de vitória/derrota e instrumentação de testes.
- Priorizar MVP, itens fora do lançamento inicial e critérios de sucesso; criar registro de decisões.
- **Entregáveis:** GDD aprovado, especificações de conteúdo/economia, backlog e critérios de aceite.
- **Gate:** nenhuma ambiguidade crítica que force reescrita do núcleo; escopo e política de monetização aprovados.

### Etapa 2 — Pré-produção técnica, segurança e UX (G2)

- Escolher arquitetura e stack após requisitos de conta, estado persistente, mercado e escalabilidade.
- Definir domínio autoritativo do servidor, modelo de dados, contratos API/eventos, autenticação, rate limits, logs, backup, restauração e proteção de economia.
- Revisar e aprovar a arquitetura, os componentes, os estados e as dependências da HUD documentados em `HUD_UX_SPEC.md` antes de implementar a interface; definir UX responsiva, acessibilidade, protótipos navegáveis e teste de usabilidade.
- Definir plano de privacidade, retenção, moderação, suporte e revisão legal/plataformas para pagamentos, VIP e caixas.
- **Entregáveis:** arquitetura aprovada, threat model, protótipos, plano de QA/observabilidade, pipeline de assets/documentação técnica.
- **Gate:** revisão técnica/segurança e aceite de experiência antes de produção em escala.

### Etapa 3 — Vertical slice e prova de diversão (G3)

- Produzir pequena fatia: lobby, 1 classe/personagem, equipe mínima definida, 1 andar, poucos inimigos e itens, combate automático, loot e inventário.
- Testar animações por código sobre PNG estático: balanço, hit/crit, morte, corte/impacto e opção de reduzir efeitos.
- Medir legibilidade, duração de encontros, compreensão de atributos e valor das decisões de equipamento; ajustar documentação após testes.
- **Entregáveis:** vertical slice jogável, resultado de playtests, plano técnico atualizado.
- **Gate:** jogadores entendem o loop e a equipe aprova performance/UX; falhas de arquitetura resolvidas antes de escalar conteúdo.

### Etapa 4 — MVP funcional (parte do G4)

- Construir núcleo de conta/progresso previsto no escopo, lobby e cura, seleção de andar, combate auto de encontros 1–3, derrota/retorno, equipe, equipamento/raridade/x, nota/poder, inventário e comparação.
- Implementar bot de poção/revive com consumíveis, lojas NPC necessárias, progressão inicial e saves seguros.
- Usar servidor autoritativo para dados persistentes e recompensas caso já haja contas online; não confiar em cliente para economia.
- Testes unitários de fórmulas e integrações do loop; telemetria de erros sem coletar dados pessoais desnecessários.
- **Gate:** fluxo completo reproduzível e sem perda/duplicação crítica de estado.

### Etapa 5 — Conteúdo, balanceamento e produção de arte (G4)

- Criar guia visual, naming e manifestos. Produzir os assets originais em lotes de 10, com revisão de consistência, transparência, tamanho, atribuição/origem e QA.
- Tabelar personagens/classes, skills, inimigos, andares, equipamentos, características, drops, economia e tutorial.
- Balancear curvas de XP/nível/loot e validar que equipamento inferior pode ser útil sem tornar raridade irrelevante.
- **Gate:** cobertura de conteúdo do MVP, localização e testes de assets aprovados; odds documentadas.

### Etapa 6 — Social, atividades compartilhadas e economia (G4 → G5)

- Implementar por prioridade: amigos/chat, guildas/chat, market da comunidade e diamantes, arena, batalhas de guilda, boss individual/em equipe/guilda/global.
- Desenvolver moderação, denúncias/bloqueio, filtros, rate limits, matchmaking, logs, operação atômica do market e ferramentas administrativas auditáveis.
- Testar transações concorrentes, retries, desconexões, abuso, fraude, inflação, bots e last-hit de boss.
- **Gate:** segurança e moderação revisadas; comércio e competição não duplicam recursos nem premiam exploits críticos.

### Etapa 7 — VIP, passe, monetização e hardening (G5)

- Implementar Free/VIP, passe e buffs somente com regras de duração, renovação, cancelamento, transparência e testes aprovados.
- Validar pagamentos, odds e requisitos legais/plataforma/região antes de ativar vendas reais.
- Testes de carga, segurança, acessibilidade, navegadores/dispositivos definidos, restauração de backup e resposta a incidentes.
- **Gate:** operações, suporte, finanças e conformidade prontos; revisão independente dos riscos críticos.

### Etapa 8 — Beta fechado / soft launch (G5)

- Liberar a grupo/região limitada, testar onboarding, retenção, estabilidade, economia e custos de serviço; coletar feedback com consentimento.
- Ajustar dificuldade, recompensas, tutorial, conteúdo e moderação; publicar notas de atualização e canal de suporte.
- **Gate:** metas de estabilidade, saúde da economia, segurança e satisfação definidas e atingidas; incidentes graves resolvidos.

### Etapa 9 — Preparação de lançamento e divulgação (G6)

- Fechar conteúdo inicial, localização, classificação etária, privacidade/termos, suporte, status page e plano de incidentes.
- Preparar site, capturas e trailer, press kit, imagens sociais, calendário editorial, comunidade oficial, FAQ, changelog e campanhas de aquisição.
- Validar funil de instalação/entrada e analytics minimizados; planejar moderação, horários de suporte e comunicação de downtime.
- **Gate:** build de release candidate aprovada, rollback e suporte ensaiados, campanha fiel ao conteúdo real.

### Etapa 10 — Lançamento e operação contínua

- Lançar com monitoramento de disponibilidade, crashes, latência, erros de transação, inflação, abuso e chamados.
- Fazer hotfix com revisão, comunicar incidentes e proteger jogadores; evitar alterações econômicas silenciosas.
- Atualizar roadmap com conteúdo sazonal, novas caixas/personagens/bosses, balanceamento e expansão; revisar documentação e AI_State em toda etapa.
- **Sucesso:** serviço estável e sustentável, comunidade segura, retenção saudável e ciclos de conteúdo com QA.

## Escopo recomendado para lançamento inicial

Priorizar uma experiência completa e pequena antes do MMO completo: lobby, progressão individual, uma seleção reduzida de personagens/skills/equipamentos/andares, bot, drops/lojas essenciais, tutorial e contas/saves seguros. Social síncrono completo, guild wars, market de diamantes, boss global e monetização devem ser fases separadas, por alto risco técnico/econômico. A composição final do MVP será decidida em G1, não presumida aqui.

## Riscos e mitigação

| Risco | Mitigação e gate |
|---|---|
| Escopo excessivo para equipe/orçamento desconhecidos | Priorizar vertical slice/MVP, estimar antes de prometer prazo; liberar sistemas por gates. |
| Economia de muitos atributos e rolls difícil de entender | Tooltip comparativo, normalização de unidades, simulação e testes com jogadores. |
| Mercado de diamantes/itens vulnerável a fraude | Servidor autoritativo, transações atômicas, rate limit, audit log, ferramentas operacionais e revisão externa. |
| VIP e caixas aleatórias podem ser pay-to-win/reguladas | Odds explícitas, revisão legal/plataforma, controles por região e balanceamento competitivo. |
| Conteúdo social traz abuso/moderação e custo operacional | Denúncia/bloqueio/filtros, equipe e política de operação antes de ativar. |
| Desconexões e automação duplicam recompensas | Persistência idempotente, testes de retry/offline e limites de farm. |
| IA/arte inconsistente ou direitos incertos | Guia, lotes de dez, QA humano, registro de origem e política de uso. |
| Buffs/VIP distorcem arena e economia | Buffs definidos com precisão, filas/regras apropriadas e testes de impacto. |

## Como atualizar

Ao concluir qualquer etapa, atualizar status, evidências, decisões, riscos e próximos passos neste arquivo e em `docs/AI_STATE.md`. Prazos só devem ser adicionados após conhecer equipe, capacidade e orçamento.
