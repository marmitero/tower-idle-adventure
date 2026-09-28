# GDD — Tower Idle Adventure

**Versão:** 0.1 — visão inicial
**Estado:** documento de pré-produção; sujeito a revisão antes da implementação
**Data da atualização:** 2026-09-28

## 1. Visão do produto

**Tower Idle Adventure** é um RPG idle 2D para navegador no qual o jogador prepara uma equipe em um lobby, escolhe um andar da torre adequado ao seu nível e deixa a equipe lutar automaticamente. O loop mistura progressão persistente, montagem de builds, procura por equipamentos com atributos variáveis e sistemas sociais que não exigem compartilhar o mundo de exploração.

**Fantasia central:** montar uma equipe cada vez melhor, observar combates rápidos e satisfatórios e encontrar uma combinação rara de equipamento, atributos e características que transforme a build.

**Público:** jogadores de RPGs de progressão, auto-battlers e idle games que preferem decisões de preparação e otimização a controle manual de cada ação.

**Plataforma e formato:** navegador; interface 2D responsiva, primeiro pensada para desktop e com adaptação para telas menores. A necessidade de suporte mobile completo será definida no escopo de produção.

## 2. Pilares de design

1. **Preparar, caçar, melhorar:** o lobby é a base de cura, equipamento, evolução, compras e configuração da automação.
2. **Combate legível e veloz:** equipes de um a três inimigos, ações guiadas por velocidade e feedback visual inequívoco para ataque, crítico, dano e derrota.
3. **Loot com decisões reais:** raridade, qualidade de rolagem e atributos permitem que um item de nível menor seja melhor para uma build específica.
4. **Idle sem perda de agência:** a caçada permanece no andar escolhido; derrotas retornam a equipe ao lobby. O avanço de andar não acontece sozinho em conta Free.
5. **Social sem mundo compartilhado:** chat, guildas, arena, mercados e chefes são serviços/sessões próprios; não há personagens de outros jogadores caminhando na hunt pessoal.
6. **Arte autoral, efeitos em código:** sprites e cenários são imagens estáticas produzidas especificamente para o jogo; animações de apresentação e combate são compostas por código.

## 3. Público, sessão e loop principal

### Loop principal

1. Escolher/criar personagem inicial e classe.
2. Entrar no lobby e consultar a equipe, equipamento, skills, inventário e lojas.
3. Curar gratuitamente no lobby; comprar poções/revives/caixas se necessário.
4. Equipar itens, fortalecer personagem e skills e configurar o bot de batalha.
5. Selecionar um andar cujo nível mínimo seja atendido e iniciar a hunt.
6. A equipe combate automaticamente encontros sucessivos (1–3 inimigos), recebe XP/moedas/materiais/itens e permanece no andar.
7. Se toda a equipe cair, a run termina e o jogador volta ao lobby; pode curar gratuitamente e retornar.
8. Comparar/reaproveitar/vender loot e voltar a preparar a equipe.

O jogo não promete recompensas offline no primeiro corte: a duração, regras de desconexão e simulação offline precisam ser aprovadas na etapa de design técnico/economia. O MVP pode manter a hunt ativa somente enquanto houver sessão válida.

### Ritmo desejado

Combates curtos, leitura visual imediata e encadeamento automático entre encontros. O jogador toma decisões antes e entre hunts; não precisa clicar em cada ataque. Duração-alvo de encontro, densidade de drops e frequência de intervenção serão definidas por testes de protótipo, não fixadas como números definitivos agora.

## 4. Classes, personagens e equipe

- O início oferece seleção de classe/personagem. O roster inicial, nomes, identidade visual, papéis e kit de skills são conteúdo a produzir e aprovar.
- Uma equipe comporta até **3 personagens simultâneos**. A composição exata (uma formação fixa vs. posições configuráveis) é decisão pendente.
- Personagens são também itens de inventário/mercado, têm raridade em estrelas de 1 a 5 e podem ser obtidos em caixas de personagem.
- Duplicatas são consumidas para evolução: proposta inicial é fundir dois exemplares da mesma identidade e mesma quantidade de estrelas para criar um exemplar com uma estrela a mais; não ultrapassa 5 estrelas. Essa regra precisa ser validada junto ao custo de aquisição e proteção contra erro.
- Slots de skill por estrela: 1★ = 2; 2★ = 3; 3★ = 4; 4★ = 5; 5★ = 5 slots e +20% de dano em todas as skills.
- As skills equipadas são limitadas pelos slots; detalhes sobre skills passivas/ativas, desbloqueio e custo de fortalecimento ainda serão desenhados.

## 5. Torre e combate

O baseline aprovado de fórmulas de dano, velocidade, alvos e traços de armas está em [Combate e balanceamento](COMBAT_DESIGN.md). Valores poderão ser ajustados após playtests, mas não permanecem pendentes de aprovação conceitual.

- Cada andar tem requisito mínimo de nível, inimigos e faixas próprias de recompensa; andares mais altos oferecem recompensas potencialmente maiores/mais raras.
- O jogador seleciona manualmente o andar. Conta VIP pode ativar opção de subir para o próximo andar após cumprir as condições de progressão; é desligada por padrão e não remove a escolha manual do jogador.
- No andar, encontros repetidos contêm equipes de 1 a 3 inimigos. Ao encerrar um encontro com vitória, outro começa automaticamente enquanto a hunt continuar.
- A proposta inicial separa Velocidade (ordem inicial e desempates) de Velocidade de Ataque (intervalo entre ações); dano, alvos, críticos e efeitos estão especificados em `COMBAT_DESIGN.md`, aguardando validação de balanceamento.
- Bot configurável pelo jogador: usar poção abaixo de um limite percentual de HP, escolher poções/revives elegíveis e ligar/desligar regras; cada skill equipada também pode ser ativada/desativada para uso automático. Uma prioridade de skills pode ser adicionada futuramente, ainda sem regra definida. Automação também prevê uma opção solicitada de retorno após derrota; comportamento exato está pendente. Itens são adquiridos no lobby/market e há atalho para loja rápida durante a batalha.
- Se a equipe for derrotada, a hunt termina e retorna ao lobby; o lobby recupera HP gratuitamente. A opção de retornar automaticamente depois da derrota pode reiniciar o mesmo andar após cura, mas essa regra precisa ser aprovada; não deve subir de andar automaticamente. Revive pode evitar o fim da luta se houver item e a automação estiver ativa, conforme regra de alvo/tempo ainda a definir.
- Classes e inimigos podem ter resistências/status; roster e balanceamento estão pendentes.

### Armas e afinidades

Além dos nove slots de equipamento, todo personagem possui um slot **Arma**. Tipos: Espada, Adaga, Machado, Maça, Besta, Cajado, Livro Arcano, Luvas e Garras. Qualquer personagem pode equipar qualquer tipo; a regra de afinidade (+5% no atributo ofensivo principal) está aprovada e documentada em `COMBAT_DESIGN.md`; atribuições no roster inicial ficam pendentes. Cada tipo possui um traço próprio: Adaga pode envenenar; Machado causa dano aumentado; Maça aumenta chance crítica; Besta aumenta velocidade de ataque; Cajado ataca todos os inimigos; Livro Arcano recupera vida por ataque conforme Ataque Especial; Luvas podem atordoar temporariamente; Garras atacam duas vezes. **Espada — Contracorte (validado):** ao receber um ataque direto de alvo único, há 20% de chance de contra-atacar imediatamente o agressor com dano físico de 50% do Ataque atual. O contra-ataque não pode ativar a si próprio nem disparar por dano ao longo do tempo. Esses valores iniciais foram validados pelo usuário; ajustes posteriores só por balanceamento/playtest. Os parâmetros baseline dos demais traços estão aprovados e detalhados em `COMBAT_DESIGN.md`; atribuições de afinidade no roster e calibração por playtests ainda serão feitas.

A característica intrínseca do tipo de arma é separada da característica aleatória adicional de itens Lendários/Celestiais; um efeito não substitui o outro. O subtipo de arma também é distinto do slot de armadura Luva.

### Apresentação visual do combate

Sprites estáticos estilo card, com balanço/avanço ao agir, piscar ao receber dano, variante de impacto crítico e duas piscadas seguidas de desaparecimento ao morrer. Efeito visual distingue corte de lâmina e impacto contundente. Partículas, números, flashes e transições são implementados em código; leitura e acessibilidade devem prevalecer sobre excesso de efeitos. A animação não precisa alterar o sprite-fonte.

## 6. Equipamentos, loot e progressão

Slots definidos: **Arma, Peitoral, Elmo, Calça, Bota, Luva, Colar, Aura, Asa e Pet**. Todo equipamento possui os oito atributos descritos na especificação de sistemas; bases por slot/tipo/nível serão tabeladas antes da implementação. O slot Arma tem nove tipos definidos nesta revisão.

Raridades: **Comum, Incomum, Raro, Épico, Lendário, Celestial**, com multiplicadores de atributos-base de 1,0; 1,2; 1,5; 2,0; 2,5; 3,0. Cada atributo do item possui seu próprio x, gerado aleatoriamente de forma independente. Regra confirmada: x é sempre um número inteiro de 1 a 50; o fator aplicado é `x/10`, de 0,1x a 5,0x em passos de 0,1. Exemplo de exibição: rolagem `x=37`, fator aplicado `×3,7`. Não usar valores fracionários como `x=4,72`.

Equipamentos Lendários e Celestiais recebem uma característica única escolhida de uma lista aprovada (ex.: roubo de vida, quebra de armadura, chance crítica, redução de cooldown). Essa característica não é escalada pela raridade ou por x; o balanceamento definirá sua força e limites.

Um item deve exibir, em tooltip/detalhe, identidade, slot, nível, raridade, atributos-base e finais, x por atributo, característica, nota, poder total, origem e condição de venda/equipamento. A nota resume a qualidade da rolagem; poder total estima contribuição de combate. Ambos são informativos e não substituem comparação atributo a atributo.

## 7. Economia e lojas

### Recursos previstos

- **Coins:** moeda padrão para loja comum e serviços definidos.
- **Diamantes:** moeda premium; podem ser adquiridos pela loja de diamantes e, conforme regra de mercado, vendidos por jogadores em troca de coins.
- **XP e materiais:** progressão de personagem, skill e fortalecimento, com fontes e sumidouros a serem tabelados.
- **Itens consumíveis:** poções, revives e caixas.

### Loja/market do jogo

- Poções de vida nas seis raridades, com cura e preço distintos.
- Revives de 30%, 50% e recuperação total; a percentagem define vida restaurada segundo regra final (HP máximo ou HP perdido deve ser decidido).
- Cinco caixas de equipamento e cinco caixas de personagem. Cada caixa define preço, pool próprio e chances; loot utiliza as mesmas regras de equipamento/personagem aplicáveis.
- Loja em Coins e loja em Diamantes. Diamantes podem pagar VIP, bônus de XP e de farm, sujeitos à revisão de monetização e regras da plataforma.
- O mercado da comunidade aceita listagens de itens e personagens por preço escolhido pelo vendedor; compra transfere o item e moeda em uma operação segura. Também permite listar diamantes por coins conforme regras antifraude.

### Salvaguardas econômicas propostas

Definir taxas/limites de listagem, prazo, cancelamento, itens vinculados e proteção contra transações duplicadas; auditar transações no servidor. Mercado de jogador é diferente da loja NPC e requer moderação e controles anti-bot. Não haverá negociação direta jogador-a-jogador fora dos sistemas registrados.

## 8. Free, VIP e monetização

- Conta Free tem acesso ao jogo base e às atividades PvE/social incluídas no escopo.
- Conta VIP inclui os recursos Free, passe de batalha com recompensas diárias, +30% XP e +15% farm.
- VIP pode ativar subida automática de andares. O buff de farm precisa definir exatamente quais recompensas afeta; bônus não devem ser aplicados de maneira ambígua ou cumulativa.
- Bônus de XP/farm também podem existir na loja de diamantes, conforme pedido.
- O design deve comunicar claramente preços, duração, chance de caixas e conteúdo pago; caixas aleatórias demandam revisão jurídica, de plataforma, classificação etária e transparência por região. Monetização não deve ser implementada antes dessa revisão.
- VIP traz conveniência e progressão mais rápida e pode afetar competitividade. Equilíbrio da arena e limites de bônus são riscos a testar; não prometer paridade competitiva até validar.

## 9. Recursos sociais e atividades

Estes recursos são serviços/sessões compartilhados, sem exploração em mapa aberto conjunto:

- Chat global e chat de guilda.
- Guildas, membros, funções e chat.
- Amizades e chat privado entre amigos.
- Arena PvP (regras, matchmaking, temporadas e combate assíncrono/ao vivo pendentes).
- Batalhas de guilda.
- Mercado da comunidade.
- Boss individual, boss em equipe, boss da guilda e boss global. Boss global é evento coletivo, com prêmio especial para o jogador que der o último golpe, além de recompensas a definir.

Chat e mercado exigem denúncia, bloqueio, filtros, limites contra spam, moderação e trilhas de auditoria. O boss global precisa ter regra transparente contra last-hit farming, desconexão e disputa de autoria.

## 10. UX e HUD

A organização espacial e arquitetura propostas para a HUD principal estão em [HUD / UX — arquitetura visual](HUD_UX_SPEC.md). A tela mantém perfil no topo esquerdo, equipe logo abaixo, navegação central no topo, automação no topo direito, batalha/HUB no centro, log embaixo e chat compacto no canto inferior direito. A HUD deve comunicar rapidamente HP/equipe, andar, encontro, automação e loot sem expor permanentemente todos os detalhes.

1. Entrada, conta e seleção/criação inicial.
2. Lobby: equipe, status, cura grátis, equipamentos, fortalecimento, skills, inventário, loja, VIP e acesso às atividades.
3. Inventário com filtros, comparação, tooltip e confirmação para destruir/fundir/listar itens.
4. Configuração do bot (limiar de poção, uso de revive, liga/desliga).
5. Seleção de andar com nível mínimo e preview de recompensas.
6. Tela de hunt: combate, HP/recursos, andar e progresso, registro de eventos, acesso à loja no canto superior; controles de pausa/retorno conforme decisão de produto.
7. Social: chat, amigos, guilda, mercado e conteúdo de grupo.
8. Perfil, VIP/passe e configurações de acessibilidade.

## 11. Direção de arte e áudio

- Arte 2D original, coesa, legível em escala pequena e exportada como PNG com transparência quando aplicável.
- Sprites/personagens, inimigos, ícones, equipamento, cenários, UI e efeitos estáticos são produzidos em **pacotes de 10 assets por vez**, cada pacote com manifesto, dimensão, transparência, naming, licença/origem e checklist de QA.
- Nada de arte de jogo gerada proceduralmente em runtime. IA pode auxiliar a criação de assets próprios, sujeitos a revisão humana e consistência; cada asset aprovado vira arquivo versionado. Efeitos de movimento são código sobre esses assets.
- Paleta, referências, tamanhos, limites de animação, pipeline e política de fontes/áudio serão fechados no guia de arte antes da produção de assets.

## 12. Acessibilidade e qualidade

Contraste e escala de texto adequados, sinais além da cor, opção de reduzir efeitos/piscadas, controle de volume, interface utilizável por teclado e avisos antes de ações irreversíveis. Considerar respeito à preferência por movimento reduzido e prevenir flashes intensos. Testes cobrem fórmulas, combate determinístico, economia transacional, responsividade, segurança e recuperação de sessão.

## 13. Escopo por fases

O MVP deve provar primeiro: seleção inicial simples, lobby, equipe, slots, atributos/raridades/nota/poder, andar, loop de combate, loot, inventário, bot de poção/revive e retorno por derrota. Multiplayer social/mercado, monetização, todas as caixas e chefes entram somente após arquitetura, segurança, política e validação do núcleo. Ver [Roadmap](ROADMAP.md).

## 14. Decisões pendentes prioritárias

1. Nome e quantidade de classes/personagens iniciais, skills e papéis.
2. Progressão de nível, XP, materiais, custos e bases por slot/nível; validar as fórmulas de ataque/defesa aprovadas em `COMBAT_DESIGN.md` durante a implementação/playtest.
3. Baseline de traços de armas e afinidade (+5% atributo ofensivo) está aprovado; atribuir afinidades ao roster inicial e avaliar ajustes apenas por playtest documentado.
4. Definição numérica e pesos para nota/poder total; tratamento de percentuais e limites.
5. Regras de morte/revive para equipe de três e valor de recuperação (máximo vs. perdido).
6. Auto-retorno após derrota (default, cura e reinício do mesmo andar) e se abrir a loja pausa o combate.
7. Duração e multiplicadores de poções; preço, chance e pool das dez caixas; odds exibidas.
8. Arena ao vivo ou assíncrona; regras de guildas e matchmaking.
9. Escopo e momento da simulação offline, persistência quando desconectado e limite de farm.
10. Plataforma de contas/pagamentos, classificação etária, regiões, privacidade, retenção e política contra abuso.
11. Limites de VIP/buffs, taxa do mercado, diamantes negociáveis e impacto no PvP.
12. Breakpoints/layout responsivo final, navegação e arte visual da HUD; dispositivos/navegadores e idiomas de lançamento.
13. Detalhes de implementação da arquitetura Supabase + Vercel (schemas, jobs, ambientes, backup), orçamento e cronograma.

Nenhuma dessas lacunas deve ser preenchida silenciosamente em código: cada decisão precisa ser registrada nesta documentação e no AI_State antes do desenvolvimento do sistema correspondente.

## 15. Arquitetura aprovada e painel administrativo

A direção tecnológica aprovada é **Vercel + Supabase**, mantendo Game Web (cliente de navegador) separado do servidor. Vercel entrega a experiência visual; Supabase concentra Auth, banco persistente e endpoints confiáveis para gameplay/economia. Dano, loot, inventário, saldo e transações nunca são decididos pelo cliente. Consulte [Arquitetura técnica](TECH_ARCHITECTURE.md).

Também é requisito aprovado um **Painel Administrativo de Conteúdo** sem necessidade de código para criar/editar/arquivar/publicar equipamentos, personagens, skills, inimigos, bosses, eventos, andares, loot e catálogos suportados. O painel será uma aplicação Vercel isolada da aplicação de jogadores, sem link no Game Web, com acesso e APIs protegidos por role administrativa validada no servidor/Supabase. Conteúdo passa por validação, rascunho, publicação versionada, auditoria e rollback; não se pode depender apenas de esconder uma URL. Nova lógica de gameplay ainda exigirá desenvolvimento, mas novos registros dos tipos suportados não exigem redeploy. Ver [especificação do Painel Administrativo](ADMIN_PANEL_SPEC.md).
