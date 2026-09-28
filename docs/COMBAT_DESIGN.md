# Combate automático e balanceamento de armas

**Versão:** 0.1 — proposta de design para G1
**Estado:** Contracorte da Espada validado pelo usuário. Fórmulas e parâmetros das outras armas são propostas iniciais para análise/playtest; não são código nem balanço final.

Este documento propõe um núcleo de combate automático coerente com os atributos e os nove tipos de arma. Onde o briefing já decidiu algo, está marcado como **confirmado**; números sugeridos aguardam análise de balanceamento. O objetivo é avançar o G1 sem esconder hipóteses.

## 1. Princípios e convenções

- O servidor/simulador resolve o combate; a HUD só apresenta eventos e envia configurações.
- Atributo **Ataque** escala dano físico; **Ataque Especial** escala dano mágico. Defesa física e Defesa Especial mitigam o tipo correspondente.
- Equipamentos fornecem seus oito atributos através da fórmula aprovada de raridade e rolagem x inteiro independente para cada atributo. Traços do tipo de arma são um efeito separado, fixo por subtipo e não multiplicado pelo x do item nem pela raridade.
- Todos podem usar qualquer arma. Afinidade dá uma vantagem moderada, nunca é requisito para equipar.
- Resultados são reprodutíveis para estado e seed iguais; empates usam uma ordem estável. As propostas devem ser simuladas em encontros com 1, 2 e 3 inimigos antes de congelar G1.

## 2. Fórmulas-base propostas

### Dano físico e mágico

Para ataque direto sem crítico:

```text
DanoBase = PoderOfensivo × CoeficienteDaAção × 100 / (100 + DefesaAlvo)
DanoFinal = max(1, floor(DanoBase × ModificadoresDeDano))
```

- `PoderOfensivo` é Ataque contra Defesa, ou Ataque Especial contra Defesa Especial.
- `CoeficienteDaAção` é 1,0 para ataque básico normal; skills e traços podem declarar outro coeficiente.
- Defesa não fica negativa. Com Defesa 100, o alvo recebe metade do dano pré-modificadores; com Defesa 300, recebe um quarto. A fórmula reduz retornos sem tornar defesa infinita.
- Ataques básicos acertam sempre na proposta inicial, pois não há atributo de precisão/evasão no conjunto definido. Esquiva só existe se uma skill/efeito a declarar.
- Calcular com precisão decimal e arredondar para baixo ao aplicar HP; um golpe que acertou causa no mínimo 1 de dano.

### Crítico

- Chance efetiva = chance crítica acumulada do personagem + modificadores planos do tipo de arma, limitada a **75%** na proposta inicial.
- Crítico multiplica o dano final mitigado por **1,5**, depois dos modificadores de dano. Multiplicador crítico adicional, se existir no futuro, é um efeito separado.
- Maça adiciona **10 pontos percentuais** de chance crítica como valor inicial de playtest, antes do limite.

### Velocidade e frequência de ação

Separar os dois atributos para que tenham funções claras:

- **Velocidade:** define a ordem inicial de ação no começo de cada encontro; maior valor age primeiro. Empate: desempate estável por formação/slot e, se ainda necessário, seed de combate.
- **Velocidade de Ataque:** define a recorrência depois da primeira ação. Proposta: `intervalo = T0 / (1 + IAS)`, com `T0 = 2,0 s` e `IAS` convertido de percentual para fração. Limitar IAS efetivo a `-50%…+100%`, dando intervalo de `4…1 s` e evitando loops extremos. Ações de skills usam o mesmo intervalo; cooldowns são medidos em tempo de simulação e não são reduzidos por IAS nesta primeira versão.
- A unidade que age recebe seu próximo horário pelo intervalo próprio; quando vários eventos empatam, Velocidade e a ordem estável decidem. O tempo real/pausado e a forma de simular tempo ocioso serão fechados na arquitetura técnica.

Esses valores (`T0` e caps) são recomendações de protótipo; ajustar após medir duração/legibilidade e combinar com bases de atributos por nível.

## 3. Alvos e skills automáticas — proposta

- Ataque básico de alvo único prioriza o inimigo com menor percentual de HP restante; empate: menor HP absoluto, depois posição/ID estável. Skills em área usam a lista de alvos declarada pela skill.
- Skill de cura, se houver, prioriza aliado vivo com menor percentual de HP; empate por posição/ID estável.
- O jogador pode ligar/desligar a automação de cada skill equipada. Quando chegar a vez da unidade, ela usa a skill habilitada e pronta de menor número de slot; se nenhuma estiver pronta/habilitada, faz ataque básico. Isso oferece comportamento determinístico até existir uma configuração de prioridade.
- Custo de recurso, cooldown e condições adicionais são declarados por skill. O ataque básico não consome energia.
- Revives e poções são regras automáticas independentes da rotação de ataque; seus gatilhos e ordem precisam ser implementados sem consumo duplicado no mesmo evento.

## 4. Traços de arma — parâmetros iniciais para playtest

Os valores abaixo são uma **proposta de primeira passagem**, não uma promessa de equilíbrio. Todo efeito deve produzir evento visual/log legível. Traços não escalam diretamente com raridade nem com x; bônus explícitos são constantes do tipo de arma.

| Arma | Atributo usado e efeito proposto | Regras para evitar abuso |
|---|---|---|
| **Espada — Contracorte** | **Validado pelo usuário:** ao receber um ataque direto de alvo único, 20% de chance de contra-atacar o agressor com dano físico de coeficiente 0,50 (50% do Ataque atual). | Reação não consome nem reinicia o intervalo de ataque; não ativa contra si própria e não dispara por dano ao longo do tempo. Usa a fórmula física e pode critar conforme a chance do personagem. |
| **Adaga — Veneno** | Ataque físico; 20% de chance por ação de arma de aplicar veneno: 3 pulsos, um por segundo, cada um com coeficiente 0,10 de Ataque físico (antes da mitigação). | Veneno não acumula; reaplicar renova a duração. Pulsos não critam e não acionam outros efeitos “ao acertar”. A resistência de chefes/PvP ainda precisa de regra própria. |
| **Machado — Dano aumentado** | Ataque físico; +15% de dano físico final em ataques básicos e skills físicas. | Não aumenta dano mágico, cura nem dano periódico; bônus é multiplicativo com a fórmula da ação. |
| **Maça — Crítico aumentado** | Ataque físico; +10 pontos percentuais de chance crítica efetiva. | Respeita teto de 75%; não aumenta dano crítico (permanece 1,5×). |
| **Besta — Velocidade de ataque** | Ataque físico à distância; +20% de IAS aditivo antes do limite global de IAS. | Não muda Velocidade/iniciativa nem reduz cooldown de skill. |
| **Cajado — Área** | Ataque Especial/Defesa Especial; atinge todos os inimigos. Contra um único alvo, coeficiente 1,0; havendo 2 ou mais, cada alvo recebe coeficiente 0,70. | Todos os alvos resolvem mitigação/crítico separadamente; sem multiplicar eventos de proc por alvo. O valor AoE deve ser testado com grupos de 1–3. |
| **Livro Arcano — Sifão Arcano** | Ataque Especial; após ataque básico mágico que acerta, cura o próprio portador em `floor(0,10 × Ataque Especial)`, limitado ao HP faltante. | Uma cura por ação, não por alvo/skill/instância de dano; não cura aliados nesta proposta. Nome é provisório. |
| **Luvas — Atordoamento** | Ataque físico; 15% de chance por ação de arma de atordoar o alvo, fazendo-o perder a próxima ação agendada. | Uma rolagem por ação; stun não acumula. Duração/imunidade de boss, PvP e resistência a controle requerem configuração de conteúdo. |
| **Garras — Golpe duplo** | Ataque físico; faz dois golpes consecutivos de coeficiente 0,60 cada contra o mesmo alvo (120% total antes de crítico). Cada golpe pode critar separadamente. | Conta como uma ação para cooldown/IAS; outros procs “ao acertar” rolam uma vez por ação, evitando dobrar veneno/efeitos acessórios. |

**Por que a Espada:** Contracorte cria uma identidade reativa e confiável no auto-combate, recompensa permanecer lutando e não se confunde com veneno da Adaga, dano do Machado, crítico da Maça, área do Cajado ou ataque duplo das Garras. Os valores de 20%/50% foram confirmados junto com o conceito pelo usuário; ainda podem ser ajustados futuramente por balanceamento sem mudar a identidade.

## 5. Afinidade de arma — proposta

- Afinidade não bloqueia equipamento. Proposta inicial: personagem pode ter **uma afinidade de arma ou nenhuma**; isso é um dado da ficha do personagem.
- Com a arma correspondente equipada, recebe **+5% multiplicativo no atributo ofensivo principal** final: Ataque para Espada/Adaga/Machado/Maça/Besta/Luvas/Garras; Ataque Especial para Cajado/Livro Arcano.
- Afinidade não altera os rolls x, bases, raridade, chances de proc, número de alvos ou número de golpes. Como aumenta o atributo principal, melhora indiretamente dano (e cura do Livro Arcano, quando pertinente).
- Os personagens com afinidade e distribuição no roster ficam para a definição do elenco inicial. O bônus de 5% é sugestão; validar se é suficiente e se há personagens sem afinidade.

## 6. Interações e estados

- Efeitos de arma, skills, características Lendárias/Celestiais, poções, revive e VIP devem ter `id`, fonte, alvo, duração, limite/stack e regra de dispel explícitos.
- Efeitos de dano periódico resolvem dano usando o tipo/defesa documentados, não podem causar crítico na proposta base e têm regra explícita de acumular/renovar.
- Atordoamento pula uma única ação agendada do alvo e então expira. Aplicações consecutivas não estendem a duração nesta primeira versão.
- Quando um alvo morre, ações/cooldowns do alvo são cancelados; efeitos periódicos ativos precisam ter regra final (proposta: expiram com o alvo).
- Bosses e PvP podem ter resistência/imunidade a controle/DoT configurada por conteúdo; ainda não definir exceções globais sem decidir seus modos.

## 7. Pendências antes de congelar G1

1. Aprovar/ajustar os números propostos para Adaga, Machado, Maça, Besta, Cajado, Livro, Luvas e Garras.
2. Aprovar bônus e distribuição de afinidades no roster.
3. Validar base de atributos/nível e se o limite de IAS, crítico e defesa mantém lutas rápidas.
4. Definir resistência de chefes/PvP a veneno/stun, cooldowns e efeitos lendários que interagem com golpes múltiplos.
5. Fechar regra de alvos para skills, buffs, cura de grupo, empate e tempos/reconexão.
6. Simular e playtestar os parâmetros na vertical slice antes de chamá-los de balanceamento final.

Nenhum número provisório deve ser tratado como oficial até ser registrado como aprovado no GDD e neste documento. Contracorte (20% / 50% Ataque) é a exceção já validada pelo usuário nesta revisão.
