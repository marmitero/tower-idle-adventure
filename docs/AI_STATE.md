# AI_State — estado vivo do projeto

## Para que serve

Este arquivo é a passagem de contexto do projeto **Tower Idle Adventure**. Deve permitir que uma pessoa ou agente retome o trabalho sem inventar decisões nem contradizer etapas anteriores. É um resumo vivo — não substitui o [GDD](GDD.md), a [especificação](SYSTEMS_SPEC.md), a [arquitetura de HUD/UX](HUD_UX_SPEC.md) nem o [roadmap](ROADMAP.md).

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
- **Marco atual:** rascunho de fórmulas de combate e balanceamento de armas documentado; Contracorte e regra de x inteiro confirmados. G1 ainda não foi aprovado e nenhuma implementação do jogo foi iniciada.
- **Estado inicial do repositório:** somente `README.md` inicial; sem código de jogo e sem AI_State prévio.
- **Documentação atual:** README e seis arquivos em `docs/`: GDD, especificação de sistemas, combate/balanceamento, arquitetura HUD/UX, Roadmap e este AI_State.
- **Validação:** nenhuma execução de jogo; revisão documental, 7 arquivos Markdown e links locais verificados, `git diff --check` passou. Fórmulas e valores de combate ainda não passaram por simulação/playtest.

## Resumo confiável do projeto

RPG idle 2D para navegador, **Tower Idle Adventure**. Jogador prepara até três personagens no lobby, escolhe manualmente um andar e deixa a equipe lutar automaticamente contra encontros de 1–3 inimigos. Vitórias encadeiam novas lutas e dão XP/moedas/loot. Derrota retorna ao lobby, onde a equipe cura gratuitamente. Autoavançar andares é um recurso VIP opcional. Conta VIP também tem passe/recompensas diárias, +30% XP e +15% farm. Social e atividades compartilhadas (chat, guilda, amigos, PvP, market e bosses) não colocam jogadores no espaço pessoal de hunt.

A equipe usa dez slots: **Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet**. Todo item possui Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, Chance Crítica, Velocidade de Ataque e Velocidade. Multiplicadores de raridade: Comum 1,0; Incomum 1,2; Raro 1,5; Épico 2,0; Lendário 2,5; Celestial 3,0. Fórmula base: `valorFinal = base × multiplicadorRaridade × (x/10)`. **Confirmado pelo usuário: x é rolado aleatoriamente e independentemente para cada atributo do equipamento, sempre como inteiro de 1–50.** O fator aplicado é `x/10`, de 0,1x a 5,0x em passos de 0,1; `x=37` significa fator `×3,7`. O exemplo `x=4,72` foi descartado: nenhum x fracionário é permitido. Lendário/Celestial podem ter uma característica aleatória extra independente da raridade/x.

Armas podem ser equipadas por qualquer personagem; afinidades nunca restringem o uso. Tipos/traços: Espada (**Contracorte validado**: 20% de chance de contra-atacar com 50% do Ataque após ataque direto de alvo único), Adaga (veneno), Machado (dano aumentado), Maça (crítico aumentado), Besta (velocidade de ataque aumentada), Cajado (atinge todos os inimigos), Livro Arcano (cura por ataque com base no Ataque Especial), Luvas (chance de atordoar) e Garras (dois ataques). Parâmetros de playtest para as demais armas e afinidade estão propostos em `COMBAT_DESIGN.md`, sem validação de balanceamento. Traço de tipo é separado da característica aleatória adicional Lendária/Celestial. Arma `Luvas` não é a armadura do slot `Luva`.

`COMBAT_DESIGN.md` propõe fórmula de mitigação `PoderOfensivo × coeficiente × 100/(100+Defesa)`, crítico de 1,5× com teto de 75%, Velocidade para ordem inicial e IAS para intervalo, alvos automáticos, skills por ordem de slot, traços numéricos e afinidade +5% ao atributo ofensivo principal. São propostas de G1, ainda sem playtest; Contracorte e x inteiro são decisões validadas.

A HUD desktop proposta mantém perfil no topo esquerdo, equipe abaixo, navegação superior central, automação no topo direito, gameplay no centro, log inferior, chat compacto embaixo à direita e overlays/painéis secundários. O documento `docs/HUD_UX_SPEC.md` descreve componentes, fluxo de dados, estados e dependências. O jogador configura poções/revives e pode ligar/desligar cada skill equipada na automação; prioridade de skills pode vir depois. A HUD também pede opção de retorno após derrota; regra exata (curar no lobby e reiniciar mesmo andar?) segue pendente. Loja rápida mantém contexto de batalha; pausa/continuação da batalha ao abrir a loja requer confirmação. Não assumir recompensas offline.

## Decisões registradas e pendências

### Confirmadas

- x independente por atributo e sempre inteiro de 1–50; o fator aplicado é `x/10`, em passos de 0,1. O exemplo fracionário `4,72` foi descartado.
- Slot Arma oficial, com os nove tipos acima; qualquer personagem equipa qualquer tipo.
- **Contracorte validado pelo usuário:** após ataque direto de alvo único recebido, 20% de chance de contra-atacar com dano físico de 50% do Ataque atual; sem recursão ou ativação por dano ao longo do tempo.
- Organização/elementos centrais da HUD registrados em `HUD_UX_SPEC.md`; arquitetura antes de qualquer implementação.
- Ao fim de toda etapa, mesmo incompleta, atualizar documentos, fazer commit e push para a branch fixa e verificar o resultado.

### A resolver antes de G1/implementação dos sistemas correspondentes

1. Validar as propostas COMBAT_DESIGN para Adaga, Machado, Maça, Besta, Cajado, Livro Arcano, Luvas e Garras; confirmar afinidade (+5% ao atributo ofensivo principal) e sua distribuição no roster.
2. Revisar as fórmulas de dano, crítico, Velocidade/IAS, seleção de alvo, skills e efeitos de status; ajustar no G1 antes de playtests.
3. Nota e poder do item/equipe: escala, pesos, normalização de percentuais e influência das características.
4. Default e regra do toggle “voltar após derrota”, incluindo cura automática/reentrada; comportamento da batalha quando loja rápida estiver aberta.
5. Prioridade/ordem de automação das skills; roster inicial, skills, slots e demais regras de progressão/personagem.
6. Base por slot/nível, materiais, poções/revives, preços, pools/odds das caixas e buffs de farm.
7. Simulação offline, resumo da sessão e retenção de eventos para responder “o que ocorreu enquanto eu estava ausente?”.
8. Wireframes/arte final da HUD, breakpoints, suporte mobile, navegação e política de efeitos reduzidos.
9. MVP/stack/backend, arena, market, monetização, segurança, moderação e privacidade.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. Revisar/aprovar ou ajustar o rascunho `COMBAT_DESIGN.md`, sobretudo magnitudes dos traços das oito outras armas, bônus/distribuição de afinidade e fórmulas-base.
2. Fechar escopo do MVP e as demais decisões críticas para G1 conforme o Roadmap; manter implementação bloqueada até esse gate.
3. Depois da aprovação de design, definir arquitetura/stack e implementar por fatias; antes da HUD, apresentar a arquitetura proposta e validar estados/dependências documentados.
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
- **Próximo passo:** revisar as propostas do documento de combate e fechar decisões pendentes para aprovação de G1.
