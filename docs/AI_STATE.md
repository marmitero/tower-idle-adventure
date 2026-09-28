# AI_State — estado vivo do projeto

## Para que serve

Este arquivo é a passagem de contexto do projeto **Tower Idle Adventure**. Deve permitir que uma pessoa ou agente retome o trabalho sem inventar decisões nem contradizer etapas anteriores. É um resumo vivo — não substitui o [GDD](GDD.md), a [especificação](SYSTEMS_SPEC.md) nem o [roadmap](ROADMAP.md).

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
- **Fase:** Etapa 0 — descoberta e documentação inicial, concluída nesta entrega.
- **Marco atual:** documentação-base em rascunho entregue para revisão; projeto de software ainda não implementado. Etapa 1/G1 depende do fechamento das decisões de design.
- **Estado do repositório ao início:** somente `README.md` inicial; sem código de jogo e sem AI_State prévio.
- **Estado do repositório após este trabalho:** README com entrada para docs e quatro documentos em `docs/` (GDD, especificação de sistemas, este AI_State e roadmap).
- **Testes:** nenhum teste de jogo executado, porque ainda não existe implementação. Revisão feita por consistência documental; não confundir com validação por usuários/balanceamento.

## Resumo confiável do pedido

RPG idle 2D de navegador chamado **Tower Idle Adventure**. Jogador seleciona classe/personagem, prepara até três personagens no lobby, equipa itens em nove slots, fortalece skills/personagens, compra recursos e caça em um andar selecionado. Combates automáticos encadeiam encontros com 1–3 inimigos; turno depende de velocidade. Nível mínimo e melhores recompensas por andar. Caçada permanece no mesmo andar, exceto avanço automático opcional VIP; derrota devolve ao lobby e cura no lobby é gratuita. Bot usa poções por limite de HP e revive se houver itens; loja acessível no lobby e por ícone no canto superior durante batalha.

Equipamentos usam Ataque, Ataque Especial, Defesa, Defesa Especial, Vida, chance crítica, velocidade de ataque e velocidade; raridades Comum a Celestial multiplicam a base por 1,0 / 1,2 / 1,5 / 2,0 / 2,5 / 3,0; x de 1–50 representa 0,1–5,0x. Lendário/Celestial têm característica única não afetada por x/raridade. Devem mostrar detalhes, nota e poder. Lojas incluem seis raridades de poções, revive 30/50/100, cinco caixas de equipamento e cinco de personagem. Personagens têm 1–5 estrelas, slots 2/3/4/5/5 e bônus 20% em dano de skills a 5★; duplicatas da mesma estrela evoluem. VIP mantém acesso Free, tem passe diário, +30% XP, +15% farm e auto-andar. Requisitos sociais: chats, amizades, guilda, PvP, guerras de guilda, market comunitário, moedas/diamantes, quatro categorias de bosses. Jogadores não compartilham o espaço da hunt. Assets serão PNGs autorais em pacotes de dez; efeitos de animação em código. Todo o design/documentação precede implementação.

## Decisões registradas / propostas ainda não aprovadas

- Fórmula explícita sugerida: `valorFinal = base × multiplicadorRaridade × (x/10)`; com x=10, exemplo de base 30 é 30 Comum / 45 Raro / 90 Celestial.
- **x individual por atributo ou único por item ainda pendente.** O pedido permite leitura por atributo, mas não fecha isso.
- Nota e poder têm propostas distintas no SYSTEMS_SPEC; pesos ainda não aprovados.
- “Espada Draco” é apenas exemplo de fórmula: não existe slot de arma na lista fornecida. Não inventar slot de arma.
- Fusão 2 unidades idênticas em identidade/estrela como proposta; validar antes de desenvolvimento.
- Sem decisão de stack, simulação offline, combate PvP, preços/odds, conteúdo inicial ou pagamentos.
- Escopo social/econômico demanda segurança autoritativa de servidor, moderação e revisão jurídica antes de produção.

## Próximos passos imediatos

1. Solicitar/recolher decisões dos itens prioritários listados em `GDD.md` e reduzir ambiguidade da especificação.
2. Revisar escopo do MVP e capacidade/orçamento; confirmar se o primeiro protótipo é somente local ou já requer backend.
3. Atualizar GDD, SYSTEMS_SPEC, ROADMAP e este arquivo com decisões aprovadas e critérios de aceite.
4. Só após o gate do Roadmap escolher arquitetura e iniciar implementação.

## Histórico de etapas

### 2026-09-28 — Etapa 0: primeira documentação

- **Entregue:** README reorganizado; GDD de visão e regras; especificação matemática/propostas de equipamentos, loot, combate, VIP e market; Roadmap do conceito ao lançamento; AI_State e protocolo de continuidade.
- **Regra processual adicionada a pedido do usuário:** ao final de toda etapa, atualizar AI_State e documentação e fazer commit + push para a branch fixa, mesmo que o trabalho esteja incompleto; verificar o push e informar o hash.
- **Incorporação:** requisitos do pedido mantidos e ambiguidades marcadas como pendentes; nenhuma feature implementada.
- **Validação:** leitura do README original e inspeção do repositório; verificação manual de fórmulas e consistência dos documentos. Nenhum teste automatizado aplicável.
- **Pendências:** decisões de design enumeradas no GDD; aprovação formal de escopo ainda não recebida.
- **Próxima etapa sugerida:** Etapa 1 do Roadmap — fechamento de design/MVP, após revisão das perguntas pendentes.
