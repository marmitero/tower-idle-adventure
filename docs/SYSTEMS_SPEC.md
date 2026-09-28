# Especificação de sistemas — Tower Idle Adventure

**Versão:** 0.1 — base para decisões de design
**Estado:** proposta inicial; números de balanceamento ainda não aprovados

Esta especificação traduz as regras fornecidas para fórmulas e invariantes testáveis. Onde há ambiguidade, a proposta está marcada como **PENDENTE**, para não transformar uma suposição em requisito definitivo.

## 1. Equipamentos e atributos

### Slots

Peitoral, Elmo, Calça, Bota, Luva, Colar, Aura, Asa e Pet.

### Atributos da ficha de equipamento

Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, Chance Crítica, Velocidade de Ataque e Velocidade. Os atributos percentuais devem ser armazenados e apresentados sem misturar pontos percentuais e frações (ex.: 10% = 0,10 internamente, se essa for a convenção escolhida).

**Observação de conteúdo:** a descrição usa “Espada Draco” como exemplo, mas espada não consta nos slots equipáveis pedidos. Até a decisão de design, a espada é apenas exemplo de cálculo; o catálogo não deve criar um slot de arma implicitamente.

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
- `x_i`: inteiro rolado entre 1 e 50 (inclusive), salvo decisão por x único.
- `MultiplicadorX_i = x_i / 10`, intervalo 0,1–5,0.
- `ValorFinal_i = Base_i × R × MultiplicadorX_i`.

Exemplo do pedido, sem x (ou com x=10, portanto multiplicador x = 1): Base de Ataque 30 resulta em 30 Comum, 45 Raro e 90 Celestial. Para Ataque Especial base 22: 22, 33 e 66. Cálculos devem manter precisão decimal internamente e arredondar apenas na apresentação, segundo regra ainda a aprovar.

**PENDENTE — modelo do x:** sugestão para atender “status gerados aleatoriamente” é rolar x independentemente para cada atributo aplicável. Isso cria perfis de item variados (ex.: ataque baixo e defesa alta), mas multiplica os dados exibidos e o espaço de armazenamento. Alternativa: um único x por item, mais simples e mais correlacionado. Decidir antes do gerador de loot.

### Característica única

Somente Lendário e Celestial recebem uma característica, sorteada da lista configurada. É independente de x e do multiplicador de raridade. A raridade pode determinar o pool elegível, mas não amplifica diretamente o valor da característica. Exemplo de estrutura: `id`, descrição, gatilho, efeito e parâmetros. Lista e magnitudes permanecem pendentes; evitar efeitos vagos como “+chance crítica” sem limite e unidade definidos.

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

Cada unidade (aliada ou inimiga) tem velocidade efetiva. Uma proposta simples é ordenar ações por maior velocidade e resolver desempates via regra estável (atributo secundário/seed de combate), mas **a semântica de velocidade ainda deve ser escolhida**: iniciativa por rodada ou intervalo entre ações contínuo.

Cada ação seleciona alvo automaticamente, executa skill/ataque elegível, calcula acerto, crítico, dano, mitigação e efeitos, aplica HP/cooldowns e emite evento visual/log. A lista de prioridade de alvos, chance de acerto, fórmula de dano, limites e ordem de efeitos serão formalizados no balanceamento.

Encontros têm 1–3 inimigos. Vitória encerra o encontro, recompensa a run e inicia o próximo encontro no andar enquanto hunt estiver ativa. Derrota total encerra hunt e retorna ao lobby. Reinício não ocorre após derrota sem intervenção do jogador.

### Bot e consumíveis

- Configuração mínima: ativar/desativar uso de poção; limite de HP percentual; ativar/desativar revive automático.
- Poção é consumida quando a condição for verdadeira e houver item no inventário. Proposta: consumir no máximo um consumível por evento de decisão e respeitar cooldown; regras exatas pendentes.
- Revive consome item elegível e restaura a percentagem configurada ao alvo derrotado, ou pode levantar o grupo conforme regra final. Momento e ordem do revive devem evitar consumir vários itens no mesmo tick.
- Loja acessada na tela de batalha é uma camada de UI; qualquer compra atualiza inventário com resposta de servidor e não pausa o combate por padrão (decisão de UX pendente).

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

Como o jogo inclui moeda negociável, VIP, PvP, chat e drops, resultados e inventários que têm valor devem ser autoritativos no servidor. O cliente é apresentação e envia intenções; não define dano, loot, cooldown, moeda nem transação. Detalhes de autenticação, persistência, privacidade, moderação e recuperação são pré-requisitos de arquitetura, não decisões de stack desta revisão.

## 9. Contratos de teste futuros

- Raridade aplica-se antes de x; com x=10, exemplos da tabela calculam exatamente.
- x só assume inteiros de 1 a 50; cada valor final corresponde a `Base × R × x/10`.
- Apenas Lendário/Celestial podem receber característica conforme pool configurado.
- Nota/poder são reproduzíveis para mesmo item e mesma versão de pesos.
- Chances de cada loot table totalizam 100% e não incluem resultados não configurados.
- Fusão nunca supera 5★ e nunca consome sem confirmação/validação do servidor.
- Ordem e dano de combate são reproduzíveis com estado/seed iguais.
- Uma compra de mercado, mesmo repetida por retry, transfere saldo/item uma única vez.
- VIP não é aplicado em duplicidade e expirado não concede buff.
- Desconexão/retorno não duplica recompensas ou revive/consumíveis.

## 10. Registro de decisões

Decisões aprovadas devem ser adicionadas a este documento com data, motivo, versão e impacto em dados/testes. Revisar este arquivo e [AI_State](AI_STATE.md) no início e no fim de cada etapa.
