# HUD / UX — arquitetura visual da tela principal

**Versão:** 0.1 — proposta documental
**Estado:** arquitetura proposta; nenhuma HUD foi implementada. Revisar junto ao GDD antes de prototipar.

Esta especificação transforma o briefing de interface em arquitetura de layout e componentes. É conceitual, original e não reproduz arte, ícones, personagens ou identidade de outro jogo. Ainda não fixa framework, medidas em pixels ou design visual final.

## 1. Objetivo e princípios

A HUD dá suporte ao loop **preparar → equipar → configurar automação → escolher andar → lutar automaticamente → obter XP/loot → melhorar**. Em cerca de dois segundos, a pessoa deve identificar seu perfil/nível, poder da equipe, personagens vivos e HP, andar e encontro atual, funcionamento da automação e recursos/loot recentes. O chat fica acessível por indicação/resumo, sem competir com a leitura da batalha.

Princípios:

- Batalha no centro e maior área visual; estado da equipe imediatamente legível.
- Informação essencial sempre visível; detalhes de atributos, comparação, odds, skills e inventário em painéis secundários/tooltips.
- Mesma estrutura de navegação e painéis no lobby e na hunt; muda o conteúdo central, não a orientação espacial.
- Painéis podem ser recolhidos; em telas menores a batalha conserva prioridade.
- Cada estado importante usa mais de um sinal visual, não apenas cor; reduzir efeitos/piscadas respeitando movimento reduzido.
- HUD apresenta o estado de sessão recebido do jogo; regras de combate/economia não são executadas nem validadas visualmente pelo cliente.

## 2. Arquitetura espacial proposta

### Desktop

1. **Barra superior persistente**
   - **Esquerda:** perfil compacto — avatar, nome, nível/XP, poder total, VIP/duração, Coins, Diamantes e ícones resumidos de buff. Atributos completos não ficam aqui.
   - **Centro:** navegação principal: Personagem, Inventário, Equipamentos, Skills, Torre, Market, Guilda, Arena, Boss e Loja. Agrupar em menu secundário se necessário.
   - **Direita:** painel compacto de Automação, recolhível, com estado geral e atalhos para configurações/consumíveis.
2. **Coluna lateral esquerda persistente, abaixo do perfil**
   - Equipe `n/3`; três cards compactos no máximo, com sprite, nome, estrelas, nível, HP, poder, buffs/debuffs e indicador de skill/cooldown quando relevante.
   - Personagem derrotado exibe texto/ícone de derrota além de HP vazio; não depender apenas da cor.
3. **Área central de gameplay**
   - Cabeçalho discreto do andar: número/nome, nível mínimo e resumo de tempo, inimigos derrotados, loot e Coins da sessão; inclui atalho visível de loja rápida no canto superior durante a hunt.
   - Palco da batalha com sprites, inimigos, HP, animações/efeitos em código, números de dano e feedback de habilidade/arma.
   - No lobby, o palco é substituído pela HUB/área de preparação; atalhos levam a cura, equipe, equipamento, skills, loja e escolha de andar.
4. **Faixa inferior central**
   - Log/progresso da sessão, compacto, rolável, minimizável e futuramente filtrável (Combate, Loot, XP, Coin, Itens, Sistema). Itens raros, loot e eventos importantes podem gerar aviso resumido não bloqueante.
5. **Canto inferior direito**
   - Chat compacto com abas Mundo, Guilda e Privado; apresenta últimas mensagens e não lidas. A expansão não deve cobrir permanentemente o palco; oferecer recolher/minimizar.
6. **Camada de painéis/overlays**
   - Inventário, personagem, equipamentos, skills, torre, market, guilda, arena, bosses, loja normal e loja rápida podem abrir como página do centro ou painel/modal contextual. Loja rápida mantém a batalha visível ao fundo e permite voltar a ela ao fechar.

Os painéis laterais e a barra superior mantêm posição sem impor dimensões finais. A grade deve encolher/reorganizar por breakpoint e permitir recolher equipe/chat/automação. Em viewport estreito, atributos secundários e mensagens antigas saem da tela antes da batalha e HP da equipe.

## 3. Árvore de componentes proposta

Nomes abaixo descrevem responsabilidades, não obrigam framework:

```text
GameHudShell
├── PersistentTopBar
│   ├── PlayerProfilePanel
│   │   ├── AvatarAndIdentity
│   │   ├── LevelXpSummary
│   │   ├── TeamPowerSummary
│   │   ├── VipAndBuffBadges
│   │   └── CurrencySummary
│   ├── PrimaryNavigation
│   │   └── NavigationItem / OverflowMenu
│   └── AutomationPanel
│       ├── AutomationStatus
│       ├── PotionRuleControl
│       ├── ReviveRuleControl
│       ├── SkillAutomationControl
│       ├── ReturnAfterDefeatToggle
│       └── VipAutoFloorControl
├── MainWorkspace
│   ├── TeamSidebar
│   │   ├── TeamHeader
│   │   └── CharacterStatusCard (0–3)
│   ├── CentralActivityColumn
│   │   ├── ActivityContextHeader (andar / modo / sessão)
│   │   ├── BattleStage | LobbyHubStage | FloorSelectionStage
│   │   ├── QuickShopLauncher (canto superior na hunt)
│   │   └── SessionEventLog
│   └── ChatDock
│       ├── ChatTabs (Mundo / Guilda / Privado)
│       ├── MessageList
│       └── MessageComposer
└── OverlayHost
    ├── QuickShopPanel
    ├── Character / Inventory / Equipment / Skills Panels
    ├── Tower / Market / Guild / Arena / Boss Panels
    ├── TooltipLayer / ConfirmationDialog / ToastQueue
    └── ConnectionAndErrorNotice
```

Os componentes recebem dados e emitem intenções/eventos de UI. Devem ser pequenos o bastante para testar apresentação/estados isoladamente e não se acoplar diretamente entre si. `GameHudShell` organiza layout; uma camada de estado/view-model converte dados de sessão e respostas dos serviços para props legíveis; serviços de domínio controlam regras e persistência.

## 4. Estado e fluxo de dados

### Snapshot de apresentação (proposta)

Um `HudSessionViewModel` somente de leitura agrega, conforme disponível:

- perfil: identidade, nível, XP, poder, VIP/expiração, buffs e saldos;
- equipe: personagens ativos, nível/estrelas, HP, estado vivo/derrotado, poder e efeitos temporários;
- atividade: modo (lobby/preparação/seleção/hunt), andar, encontro, inimigos, duração e contadores da sessão;
- automação: configurações habilitadas, limiar de HP, consumíveis elegíveis/contagens, skills automáticas habilitadas por slot e estado de cada regra;
- progresso: feed recente de eventos, XP/Coin/itens e resumo da sessão;
- comunicação: abas habilitadas, últimas mensagens, não lidas e estado da conexão.

A HUD renderiza o snapshot e envia comandos intencionais — por exemplo, `SetPotionRule`, `SetReviveRule`, `SetSkillAutoRule`, `SelectFloor`, `OpenQuickShop`, `EquipItem` e `SendChatMessage`. A autoridade do servidor/jogo confirma compras, inventário, drops, HP, combate, chat e alterações persistentes. A UI pode mostrar carregamento/pendente e erro/reconexão; não deve afirmar consumo ou compra antes de confirmação.

### Dependências entre componentes

- `PlayerProfilePanel` depende de perfil/progressão/carteira/VIP; abre detalhes do personagem ou loja conforme ação.
- `CharacterStatusCard` depende de snapshot da equipe/combate; abre detalhes/skills do membro e reflete eventos de HP/derrota.
- `ActivityContextHeader` e `BattleStage` dependem de modo, andar, encontro e eventos de batalha; a lista de eventos também alimenta `SessionEventLog`.
- `AutomationPanel` depende da configuração do bot, skills automáticas equipadas e estoques elegíveis; mudar controles envia comandos, e a confirmação/erro atualiza estado e badge.
- `QuickShopPanel` depende do catálogo/saldo/estoque atual; compra atualiza perfil/inventário/log quando confirmada, sem retirar a pessoa do contexto da hunt.
- `ChatDock` depende do serviço social e permissões de canal; sua expansão não muda o estado da batalha.
- `PrimaryNavigation` escolhe uma view/painel dentro de `OverlayHost`; não apaga sessão nem reinicia a hunt.

Se sessão estiver desconectada ou desatualizada, mostrar aviso e último estado confirmado; comandos que possam alterar economia devem aguardar conexão/validação. Recuperação e sincronização de sessão serão definidas na arquitetura online.

## 5. Estados de tela e máquina de transição

Separar **modo principal**, **estado derivado da batalha** e **overlays** para evitar dezenas de telas duplicadas.

### Modos principais

- **LOBBY:** HUB, cura gratuita e preparação.
- **PREPARAÇÃO:** personagem, equipe, equipamentos e skills.
- **SELEÇÃO DE ANDAR:** requisitos e preview de recompensas.
- **BATALHA:** hunt ativa e encontros encadeados.

### Estados derivados/visuais

- **BATALHA EM ANDAMENTO:** HP, atores e automação ativos.
- **EVENTO DE LOOT:** realce temporário no feed/toast; não bloqueia o combate.
- **PERSONAGEM FERIDO:** HP reduzido mostrado no card correspondente.
- **PERSONAGEM DERROTADO:** card marca estado e mantém dados da equipe.
- **EQUIPE DERROTADA:** termina hunt e leva ao fluxo de retorno/lobby.
- **CONEXÃO/RECONEXÃO:** estado informativo sobre atualização e comandos pendentes.

### Overlays independentes

- **LOJA RÁPIDA ABERTA:** painel/modal sobre o contexto; ao fechar, retorna à batalha/lobby que estava ativo. O combate continua, salvo futura regra de pausa aprovada.
- **MENU SECUNDÁRIO:** qualquer módulo aberto via navegação; manter sessão e contexto.
- Tooltip, confirmação, mensagens de sistema e avisos são camadas menores e não trocam modo principal.

### Transições

`LOBBY → PREPARAÇÃO → SELEÇÃO DE ANDAR → BATALHA → (encontro seguinte → BATALHA)`.

`BATALHA → EQUIPE DERROTADA → LOBBY`; cura gratuita acontece no lobby. A solicitação de toggle **“Voltar após derrota”** é registrada como automação adicional, mas a semântica ainda precisa ser aprovada: proposta a validar é voltar ao lobby, curar gratuitamente e reiniciar o mesmo andar selecionado, sem autoavançar. Toggle desligado não reinicia. O autoavanço para outro andar continua sendo exclusivamente VIP.

Abrir/fechar overlay não é transição de modo principal. Nenhum resumo de sessão implica recompensas offline: cálculo e concessão offline ainda são pendentes. Quando houver dados persistidos, um resumo da última sessão pode comunicar “o que aconteceu” sem atribuir ganhos que não foram validados.

## 6. Painel de automação

Exibir estado ativo/inativo e recursos restantes. Controles planejados:

- poção: ligar/desligar, limiar percentual de HP e raridades/tipos elegíveis;
- revive: ligar/desligar e tipos 30%/50%/total elegíveis;
- skills automáticas: ativar/desativar cada skill equipada por slot; interface preparada para uma prioridade futura (buff, ofensiva, controle, ultimate), sem fixar ordem ou comportamento até a regra ser definida;
- voltar após derrota: toggle solicitado; condição e interação com cura automática aguardam regra final;
- auto subir andar: visualmente identificado como VIP; comportamento e requisitos definidos pela progressão da torre.

Se estoque elegível acabar, não sugerir que a automação segue funcionando: mostrar `DESATIVADA — SEM POÇÕES/REVIVES` (ou estado equivalente), contagem e atalho da loja. Frequência de atualização e validação pertencem à camada de domínio/servidor.

## 7. HUD de combate e armas

A batalha mostra no palco os eventos visualmente relevantes: avanço/balanço de ação, dano/crit, hit recebido, efeitos de lâmina/impacto/magia, status aplicados e morte. Feedback deve corresponder ao evento confirmado pela simulação, sem efeitos enganosos.

O feed e indicadores reconhecem traços de arma: veneno da Adaga, dano aumentado do Machado, crítico da Maça, velocidade de ataque da Besta, ataque em área do Cajado, cura do Livro Arcano, atordoamento das Luvas, ataque duplo das Garras e **Contracorte** da Espada (contra-ataque visual de corte). Contracorte foi validado (20% de chance, 50% do Ataque); os demais números de armas permanecem em proposta e não devem aparecer como valores finais na UI antes da aprovação. Fórmulas e gatilhos estão em `COMBAT_DESIGN.md` e `SYSTEMS_SPEC.md`.

## 8. Regras de conteúdo e detalhes fora da HUD

- Perfil resume; tela de personagem mostra atributos completos.
- Cards da equipe resumem HP, poder, nível/estrelas, buffs/debuffs e estado. Skills/cooldowns só quando significativos/legíveis.
- Tooltip/painel de item revela slot/subtipo, raridade, nível, base, multiplicador de raridade, **x inteiro próprio de cada atributo**, fator aplicado (`x/10`, exibido em passos de 0,1), valor final, característica, poder e nota. Exemplo: `Rolagem x: 37; fator: ×3,7`; nunca exibir rolagens como `x=4,72`.
- Equipment view apresenta dez slots: arma, peitoral, elmo, calça, bota, luva (armadura), colar, aura, asa e pet. O subtipo de arma é separado do slot de armadura “Luva”.
- Tela de comparação deve explicar diferenças de stats e afinidade quando sua regra estiver definida; estrelas/raridade não substituem os dados reais.
- Banners de item raro/loot são concisos e podem ser desligados/reduzidos em acessibilidade; log mantém histórico conforme política de sessão.

## 9. Responsividade, acessibilidade e hierarquia

Prioridade visual: 1) batalha, 2) HP/estado da equipe, 3) andar/encontro, 4) automação/estoque, 5) progresso/loot, 6) perfil, 7) navegação, 8) chat, 9) detalhes secundários.

Em resoluções menores: recolher automação/chat/equipe em painéis acionáveis, transformar navegação em overflow e abrir módulos em camada; não reduzir excessivamente a área central. Desktop é prioridade inicial; suporte mobile completo continua pendente.

A UI deve suportar navegação por teclado/foco visível, texto legível e contraste, tooltips acessíveis por foco/clique (não só hover), sinais redundantes para morte/alertas, redução de animações/piscadas e alertas sonoros opcionais. Limites para flashes e frequência de notificações devem ser validados.

## 10. Escopo pendente antes do protótipo

- Breakpoints, resoluções e proporções finais; layout mobile e densidade visual.
- Visual art direction (tipografia, paleta, componentes, ícones e estados).
- O que ocorre ao abrir a loja durante batalha (pausa ou combate contínuo; proposta: contínuo).
- Defaults, escopo e condições da automação de retorno após derrota, cura automática e reinício da hunt.
- Política de histórico e resumo da sessão, especialmente após fechar navegador/offline.
- Semântica de poder da equipe e critério para sumarização na barra de perfil.
- Hierarquia/organização dos dez itens de navegação e permissões por conta.
- Prioridade/ordem e critérios de uso automático das skills.
- Números finais dos efeitos das armas e buffs/debuffs que aparecem nos cards.

Antes de implementar a HUD: ler AI_State, GDD e esta especificação; conferir o estado do repositório; propor/validar a arquitetura, estados e dependências; registrar decisões; então implementar apenas após os gates do Roadmap. Ao fechar a etapa, executar testes aplicáveis e atualizar AI_State, documentação, commit e push, inclusive se o trabalho continuar parcial.
