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
- **Fase:** Etapa 0 — descoberta e documentação inicial, com complementos de escopo registrados nesta revisão.
- **Marco atual:** documentação conceitual e proposta de HUD; G1 ainda depende de fechar decisões críticas. Nenhuma implementação do jogo foi iniciada.
- **Estado inicial do repositório:** somente `README.md` inicial; sem código de jogo e sem AI_State prévio.
- **Documentação atual:** README e cinco arquivos em `docs/`: GDD, especificação de sistemas, arquitetura HUD/UX, roadmap e este AI_State.
- **Validação:** nenhum teste de jogo aplicável ainda; revisão de consistência documental, links Markdown locais e `git diff --check` concluídos. Isso não substitui playtest ou aprovação de design.

## Resumo confiável do projeto

RPG idle 2D para navegador, **Tower Idle Adventure**. Jogador prepara até três personagens no lobby, escolhe manualmente um andar e deixa a equipe lutar automaticamente contra encontros de 1–3 inimigos. Vitórias encadeiam novas lutas e dão XP/moedas/loot. Derrota retorna ao lobby, onde a equipe cura gratuitamente. Autoavançar andares é um recurso VIP opcional. Conta VIP também tem passe/recompensas diárias, +30% XP e +15% farm. Social e atividades compartilhadas (chat, guilda, amigos, PvP, market e bosses) não colocam jogadores no espaço pessoal de hunt.

A equipe usa dez slots: **Arma, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet**. Todo item possui Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, Chance Crítica, Velocidade de Ataque e Velocidade. Multiplicadores de raridade: Comum 1,0; Incomum 1,2; Raro 1,5; Épico 2,0; Lendário 2,5; Celestial 3,0. Fórmula base: `valorFinal = base × multiplicadorRaridade × (x/10)`. **Confirmado pelo usuário: x é rolado aleatoriamente e independentemente para cada atributo do equipamento, sempre como inteiro de 1–50.** O fator aplicado é `x/10`, de 0,1x a 5,0x em passos de 0,1; `x=37` significa fator `×3,7`. O exemplo `x=4,72` foi descartado: nenhum x fracionário é permitido. Lendário/Celestial podem ter uma característica aleatória extra independente da raridade/x.

Armas podem ser equipadas por qualquer personagem; afinidades futuras não restringirão o uso. Tipos/traços: Espada (proposta **Contracorte**, ainda aguardando aprovação), Adaga (veneno), Machado (dano aumentado), Maça (crítico aumentado), Besta (velocidade de ataque aumentada), Cajado (atinge todos os inimigos), Livro Arcano (cura por ataque com base no Ataque Especial), Luvas (chance de atordoar) e Garras (dois ataques). Valores finais, chances, durações e afinidades continuam pendentes. O traço fixo do subtipo de arma é separado da característica adicional aleatória Lendária/Celestial. Arma `Luvas` não é a armadura do slot `Luva`.

A HUD desktop proposta mantém perfil no topo esquerdo, equipe abaixo, navegação superior central, automação no topo direito, gameplay no centro, log inferior, chat compacto embaixo à direita e overlays/painéis secundários. O documento `docs/HUD_UX_SPEC.md` descreve componentes, fluxo de dados, estados e dependências. O jogador configura poções/revives e pode ligar/desligar cada skill equipada na automação; prioridade de skills pode vir depois. A HUD também pede opção de retorno após derrota; regra exata (curar no lobby e reiniciar mesmo andar?) segue pendente. Loja rápida mantém contexto de batalha; pausa/continuação da batalha ao abrir a loja requer confirmação. Não assumir recompensas offline.

## Decisões registradas e pendências

### Confirmadas

- x independente por atributo e sempre inteiro de 1–50; o fator aplicado é `x/10`, em passos de 0,1. O exemplo fracionário `4,72` foi descartado.
- Slot Arma oficial, com os nove tipos acima; qualquer personagem equipa qualquer tipo.
- Proposta para Espada: **Contracorte**, contra-ataque físico após sofrer ataque direto de alvo único; recomendação inicial de 20% de chance e 50% do Ataque atual, aguardando aprovação/balanceamento.
- Organização/elementos centrais da HUD registrados em `HUD_UX_SPEC.md`; arquitetura antes de qualquer implementação.
- Ao fim de toda etapa, mesmo incompleta, atualizar documentos, fazer commit e push para a branch fixa e verificar o resultado.

### A resolver antes de G1/implementação dos sistemas correspondentes

1. Aprovar/ajustar Contracorte (chance, coeficiente, interações com crítico/defesa/cooldown) e definir números/limites dos outros traços de arma e regras de afinidade.
2. Nota e poder do item/equipe: escala, pesos, normalização de percentuais e influência das características.
3. Fórmulas de combate, turno/velocidade, cooldown, alvos, status e cura do Livro Arcano.
4. Default e regra do toggle “voltar após derrota”, incluindo cura automática/reentrada; comportamento da batalha quando loja rápida estiver aberta.
5. Prioridade/ordem de automação das skills; roster inicial, skills, slots e demais regras de progressão/personagem.
6. Base por slot/nível, materiais, poções/revives, preços, pools/odds das caixas e buffs de farm.
7. Simulação offline, resumo da sessão e retenção de eventos para responder “o que ocorreu enquanto eu estava ausente?”.
8. Wireframes/arte final da HUD, breakpoints, suporte mobile, navegação e política de efeitos reduzidos.
9. MVP/stack/backend, arena, market, monetização, segurança, moderação e privacidade.

Não preencher essas lacunas silenciosamente no código; registrar decisão, motivo e impacto nos documentos relevantes.

## Próximos passos

1. Validar a proposta Contracorte (ou escolher outra) e definir os parâmetros dos traços de arma e afinidades; x inteiro 1–50 está fechado.
2. Fechar escopo do MVP e as demais decisões críticas para G1 conforme o Roadmap.
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
- **Próximo passo:** validar/ajustar Contracorte e continuar o fechamento do design G1.
