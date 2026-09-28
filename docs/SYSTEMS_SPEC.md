# Especificação de sistemas — Tower Idle Adventure

**Versão:** 0.1 — base para decisões de design
**Estado:** baseline de combate/armas v0.1 aprovado pelo usuário; implementação e playtests pendentes.

Esta especificação traduz as regras aprovadas e pendências abertas em fórmulas e invariantes testáveis. Decisões novas não devem ser assumidas em silêncio: marcar como **PENDENTE** até aprovação.

## 1. Equipamentos e atributos

### Slots

**Arma**, Peitoral, Elmo, Calça, Bota, Luva (armadura), Colar, Aura, Asa e Pet. Arma é um slot oficial. Seus subtipos são Espada, Adaga, Machado, Maça, Besta, Cajado, Livro Arcano, Luvas e Garras. “Luvas” como arma não é o mesmo que o slot de armadura “Luva”. Qualquer personagem pode equipar qualquer arma; afinidades são bônus/eficiências futuras, ainda sem fórmula e sem restrição de uso.

### Atributos da ficha de equipamento

Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, Chance Crítica, Velocidade de Ataque e Velocidade. Todo equipamento, inclusive qualquer arma, possui todos esses oito atributos e uma rolagem `x_i` independente para cada atributo. Os atributos percentuais devem ser armazenados e apresentados sem misturar pontos percentuais e frações (ex.: 10% = 0,10 internamente, se essa for a convenção escolhida).

**Observação:** espada é um subtipo de arma oficial. O exemplo “Espada Draco” não define por si só seu traço; Contracorte foi posteriormente sugerido e validado pelo usuário. Os números e regras-base constam abaixo e em [COMBAT_DESIGN.md](COMBAT_DESIGN.md).

### Multiplicadores

| Raridade | Multiplicador R |
|---|---:|
| Comum | 1,0 |
| Incomum | 1,2 |
| Raro | 1,5 |
| Épico | 2,0 |
| Lendário | 2,5 |
| Celestial | 3,0 |

Para cada atributo `i`:

- `Base_i`: valor-base tabulado para aquele item/slot/nível.
- `x_i`: rolagem gerada aleatoriamente **e independentemente para cada atributo** do equipamento; nunca há obrigação de um único x compartilhado pelo item.
- Regra confirmada pelo usuário: `x_i` é sempre inteiro de 1 a 50 (inclusive); `MultiplicadorX_i = x_i / 10`, intervalo 0,1–5,0 em passos de 0,1. Não gerar nem exibir x fracionário, como 4,72.
- `ValorFinal_i = Base_i × R × MultiplicadorX_i`.

Exemplo do pedido, sem x (ou com x=10, portanto multiplicador x = 1): Base de Ataque 30 resulta em 30 Comum, 45 Raro e 90 Celestial. Para Ataque Especial base 22: 22, 33 e 66. Cálculos mantêm precisão decimal internamente e arredondam apenas na apresentação. Para evitar confusão entre rolagem e fator, tooltip pode mostrar ambos: `Rolagem x: 37` e `Fator aplicado: ×3,7`.

### Característica única de raridade

Somente Lendário e Celestial recebem uma característica adicional sorteada da lista configurada. É independente de x e do multiplicador de raridade. A raridade pode determinar o pool elegível, mas não amplifica diretamente o valor da característica. Exemplo de estrutura: `id`, descrição, gatilho, efeito e parâmetros. Lista e magnitudes permanecem pendentes; evitar efeitos vagos como “+chance crítica” sem limite e unidade definidos.

### Traço intrínseco do tipo de arma

Todo subtipo de arma possui seu traço de tipo, independentemente de o item ser Comum ou Celestial. Este traço não é a característica aleatória adicional de raridade; os dois efeitos podem coexistir em Lendário/Celestial.

| Tipo | Baseline aprovado | Integrações / referência |
|---|---|---|
| Espada | **Contracorte:** 20% de chance de contra-atacar por ataque direto de alvo único recebido, com dano físico de 50% do Ataque; sem recursão ou proc por DoT. | Usa fórmula física e chance crítica do personagem; ver COMBAT_DESIGN. |
| Adaga | 20% por ação para aplicar veneno: 3 pulsos de 10% do Ataque, 1 por segundo; não acumula, reaplicar renova. | Pulsos mitigados por Defesa física, sem crítico; resistência por boss/PvP configurada em conteúdo. |
| Machado | +15% de dano físico final em ataques básicos e skills físicas. | Não aumenta dano mágico, cura nem DoT. |
| Maça | +10 pontos percentuais de chance crítica. | Teto crítico 75%; multiplicador de crítico 1,5×. |
| Besta | +20% de Velocidade de Ataque aditiva. | Sujeita ao cap global de IAS; não reduz cooldowns. |
| Cajado | Ataque Especial atinge todos os inimigos; coeficiente 1,0 em alvo único e 0,70 por alvo quando há múltiplos. | Cada alvo tem mitigação/crítico próprios; ver COMBAT_DESIGN. |
| Livro Arcano | Ataque Especial; ataque básico que acerta cura o portador em 10% do Ataque Especial. | Uma cura por ação, limitada ao HP faltante; não cura aliados no baseline. |
| Luvas (arma) | 15% por ação de arma para atordoar e fazer o alvo perder a próxima ação. | Não acumula; exceções de boss/PvP são configuradas por conteúdo. |
| Garras | Dois golpes de 0,60 cada contra o mesmo alvo (120% no total); cada golpe pode critar. | Conta como uma ação; outros procs por acerto disparam uma vez por ação. |

Qualquer personagem pode equipar qualquer tipo; afinidade não bloqueia o uso. Baseline aprovado: afinidade dá +5% multiplicativo ao atributo ofensivo principal final (Ataque ou Ataque Especial, conforme arma); personagens específicos são definidos no roster. Detalhes em [COMBAT_DESIGN.md](COMBAT_DESIGN.md). A luva do slot de armadura e o tipo de arma Luvas devem ser IDs distintos.

## 2. Nota e poder do item

São duas métricas diferentes:

- **Nota de qualidade:** estima se as rolagens foram altas para aquele item, nível e raridade. Proposta: média ponderada de `x_i / 50` dos atributos presentes; exibir como percentagem/escala legível. Característica não entra na nota e bônus de raridade fica separado, para a nota não confundir qualidade da rolagem com nível de raridade.
- **Poder total:** estimativa da contribuição do item para combate, com pesos de atributo calibrados por testes. Proposta de fórmula parametrizada: `Poder = Σ (ValorFinal_i × Peso_i) + PoderCaracterística`. Os pesos devem normalizar unidades (HP, chance %, velocidade) e podem variar por classe ou ser globais.

Essas fórmulas são propostas, não balanceamento aprovado. Não usar soma simples de HP com percentuais. UI deve mostrar a nota, poder e diferenças de cada atributo ao comparar; nenhuma pontuação deve decidir automaticamente o melhor item sem considerar a build.

## 3. Loot e geração

A geração de item é lógica aleatória com tabelas explícitas, reprodutível por seed para debug/testes. Isso não significa gerar arte procedural: identidade e arte vêm de assets estáticos aprovados.

Pipeline conceitual do drop:

1. Determinar tabela de loot do andar/encontro/caixa.
2. Sortear tipo/identidade e raridade segundo chances documentadas.
3. Buscar atributos-base definidos para item, slot e nível.
4. Sortear x conforme modelo aprovado e calcular valores finais.
5. Se Lendário/Celestial, sortear característica elegível.
6. Calcular nota/poder; persistir rolagens e origem para auditoria.

Toda caixa deve declarar chances completas (soma = 100%), itens possíveis, nível/raridade, duplicatas e proteção contra conteúdo inválido; odds precisam ser visíveis ao jogador. Caixas do mercado e drops devem usar o mesmo gerador canônico.

## 4. Personagens e estrelas

- Estrelas possíveis: 1 a 5.
- Slots de skill: `{1:2, 2:3, 3:4, 4:5, 5:5}`.
- Bônus 5★: +20% dano em todas as skills.
- Proposta para fusão: dois personagens de mesma identidade e mesma estrela consomem-se e geram um da estrela seguinte; duas unidades 5★ não podem evoluir além de 5★. **PENDENTE:** requisitos extras, custo, itens bloqueados/à venda e proteção por confirmação.
- O mercado precisa guardar identidade, estrela, skills/atributos e estado de vinculação. Compra/venda não deve duplicar o mesmo personagem nem permitir vender a unidade ativa sem confirmação explícita.

## 5. Combate automático

### Ordem e ciclo

A proposta de iniciativa/recorrência já está registrada em [COMBAT_DESIGN.md](COMBAT_DESIGN.md): Velocidade determina a ordem inicial; Velocidade de Ataque define o intervalo entre ações, com desempates estáveis. É uma decisão de design proposta para G1, ainda aguardando validação e playtest.

Cada ação seleciona alvo automaticamente, executa skill/ataque elegível, calcula acerto, crítico, dano, mitigação e efeitos, aplica HP/cooldowns e emite evento visual/log. Baseline aprovado para dano, ordem, alvos, limites e traços está em [COMBAT_DESIGN.md](COMBAT_DESIGN.md). Valores podem ser ajustados com evidência de playtest; não reabrir a aprovação silenciosamente. Afinidade nunca restringe quem equipa a arma.

Encontros têm 1–3 inimigos. Vitória encerra o encontro, recompensa a run e inicia o próximo encontro no andar enquanto hunt estiver ativa. Derrota total encerra hunt e retorna ao lobby. A HUD solicita uma opção de retorno após derrota; regra candidata é curar gratuitamente no lobby e reiniciar o mesmo andar se o jogador tiver ativado a opção. Isso ainda requer confirmação, e não autoriza autoavanço de andar (exclusivo VIP). Sem automação aprovada/ativa, reinício não ocorre após derrota.

### Bot e consumíveis

- Configuração proposta: ativar/desativar poções; limiar de HP; escolher raridades elegíveis; ativar/desativar revive e tipos elegíveis (30%/50%/total); ligar/desligar cada skill equipada na automação; toggle de retorno após derrota solicitado; auto subir andar VIP.
- Prioridade/ordem de skills pode ser acrescentada futuramente (ex.: buff, ofensiva, controle, ultimate), mas a ordem, cooldowns e critérios de uso ainda não estão definidos.
- Poção é consumida quando a condição for verdadeira e houver item no inventário. Proposta: consumir no máximo um consumível por evento de decisão e respeitar cooldown; regras exatas pendentes. Se o estoque elegível acabar, HUD informa que a regra não pode operar e oferece loja.
- Revive consome item elegível e restaura a percentagem configurada ao alvo derrotado, ou pode levantar o grupo conforme regra final. Momento e ordem do revive devem evitar consumir vários itens no mesmo tick.
- A automação de retorno após derrota é solicitada, mas default, condição e relação com cura grátis/reinício do mesmo andar precisam ser aprovados; não presume subida de andar.
- Loja acessada na tela de batalha é uma camada modal/painel da HUD, mantendo o contexto e mostrando a batalha. Proposta é o combate continuar ao fundo; comportamento de pausa precisa ser aprovado.

## 6. Progressão e recursos

Andares definem nível mínimo e faixas de loot/XP/moedas. Nível do jogador não aumenta acesso de forma automática: cada novo andar precisa ser selecionado manualmente, salvo toggle VIP. Derrota devolve ao lobby; cura no lobby é gratuita.

VIP: +30% XP e +15% farm. **PENDENTE:** fórmula (multiplicativo ou aditivo), conteúdo abrangido por farm, arredondamento, limites e interação com bônus temporários. Registrar fonte e expiração de cada buff para evitar empilhamento duplicado.

## 7. Market da comunidade

Invariantes propostos para backend:

- Operação de compra atômica: verificar anúncio ativo, saldo e propriedade; debitar/creditar; transferir item; marcar anúncio vendido em uma única transação idempotente.
- Nunca aceitar saldo, preço final ou propriedade informados como verdade pelo cliente; o servidor valida cada campo.
- Anúncios de diamantes por coins seguem mesma atomicidade, trilha de auditoria e regras contra wash trading/contas automatizadas.
- Catálogo, taxas, limites, expiração e itens negociáveis configurados no servidor.
- Proteção contra duplicação em retries/desconexão, logs de fraude, limites de taxa, fluxo de denúncia e recuperação administrativa auditada.

## 8. Conta, sessão e recursos online

Como o jogo inclui moeda negociável, VIP, PvP, chat e drops, resultados e inventários que têm valor devem ser autoritativos no servidor. A stack aprovada é **Game Web na Vercel** e **servidor Supabase** (Auth, PostgreSQL, Edge Functions e serviços selecionados), separados por API autenticada. O cliente é apresentação e envia intenções; não define dano, loot, cooldown, moeda nem transação. O desenho e seus limites estão em [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md).

O CMS administrativo será uma aplicação Vercel separada, sem acesso público para jogadores, com roles checadas pelo servidor e RLS/Edge Functions. Escrita de conteúdo nunca usa permissões do cliente comum. Ver [ADMIN_PANEL_SPEC.md](ADMIN_PANEL_SPEC.md). Detalhes de schema, privacidade, moderação, jobs e recuperação serão fechados na pré-produção técnica.

## 9. Interface e autoridade dos dados

A composição da HUD e seus estados/dependências estão em [HUD_UX_SPEC.md](HUD_UX_SPEC.md). A HUD apresenta um snapshot/view-model de estado confirmado e emite intenções; ela não decide combate, loot, consumo, preços ou propriedade de itens. Ex.: configurar uma skill automática deve persistir/receber confirmação da camada de domínio; abrir um painel não deve reiniciar nem abandonar a hunt.

## 10. Contratos de teste futuros

- Raridade aplica-se antes de x; com x=10, exemplos da tabela calculam exatamente.
- Cada atributo recebe sua própria rolagem x, independente das demais; x assume apenas inteiros de 1 a 50, nunca casas decimais, e cada valor final corresponde a `Base × R × x/10`.
- Personagem pode equipar qualquer subtipo de arma; afinidade não bloqueia equipar.
- Cada subtipo ativa seu traço documentado; Contracorte validado tem 20% de chance e 50% de Ataque, sem recursão nem proc por dano periódico.
- Apenas Lendário/Celestial podem receber característica adicional de raridade conforme pool configurado, além do traço de tipo da arma.
- Nota/poder são reproduzíveis para mesmo item e mesma versão de pesos.
- Chances de cada loot table totalizam 100% e não incluem resultados não configurados.
- Fusão nunca supera 5★ e nunca consome sem confirmação/validação do servidor.
- Ordem e dano de combate são reproduzíveis com estado/seed iguais.
- Uma compra de mercado, mesmo repetida por retry, transfere saldo/item uma única vez.
- VIP não é aplicado em duplicidade e expirado não concede buff.
- Desconexão/retorno não duplica recompensas ou revive/consumíveis.

## 11. Registro de decisões

Decisões aprovadas devem ser adicionadas a este documento com data, motivo, versão e impacto em dados/testes. Revisar este arquivo e [AI_State](AI_STATE.md) no início e no fim de cada etapa.
