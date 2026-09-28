# Tower Idle Adventure

**Tower Idle Adventure** é um RPG idle automático 2D para navegador, centrado em uma torre de andares, progressão de equipe e batalhas PvE automáticas.

> **Fase atual: G2 em andamento.** Há documentação técnica, click-through UX sem backend e uma migration-base de schema testada apenas com PGlite; Supabase, jogo, gameplay, HUD de produção e Admin Web não foram provisionados/implementados. O baseline de MVP foi decidido pelo agente sob autorização explícita do usuário e pode ser ajustado por ele; os números ainda não foram validados em playtest.

## Documentação do projeto

- [GDD — visão e regras do jogo](docs/GDD.md)
- [Escopo e decisões do MVP](docs/MVP_DECISIONS.md)
- [Especificação dos sistemas e fórmulas](docs/SYSTEMS_SPEC.md)
- [Proposta de combate e balanceamento das armas](docs/COMBAT_DESIGN.md)
- [Arquitetura visual da HUD e UX](docs/HUD_UX_SPEC.md)
- [Arquitetura técnica Vercel + Supabase](docs/TECH_ARCHITECTURE.md)
- [Blueprint técnico detalhado do G2](docs/G2_TECHNICAL_BLUEPRINT.md)
- [Migration-base e smoke tests PostgreSQL/PGlite](supabase/migrations/20260928000000_g2_core_schema.sql) — 9 testes locais; não equivale a validar Supabase CLI/Data API. Veja também [`supabase/README.md`](supabase/README.md) para escopo e comandos.
- [Threat model do MVP](docs/THREAT_MODEL.md)
- [Blueprint UX e plano de usabilidade G2](docs/G2_UX_BLUEPRINT.md)
- [Protótipo HUD clicável (dados fictícios, sem backend)](prototypes/g2-hud/index.html)
- [Painel administrativo de conteúdo](docs/ADMIN_PANEL_SPEC.md)
- [AI_State — estado e passagem de contexto entre etapas](docs/AI_STATE.md)
- [Roadmap — etapas até lançamento e divulgação](docs/ROADMAP.md)

## Princípios já definidos

- O jogador controla uma equipe de até três personagens; as lutas e a seleção de alvos/turnos são automáticas.
- No MVP, a torre avança por seleção manual e não existe VIP/autoavanço; VIP é pós-MVP.
- Equipamentos usam atributos-base, multiplicador aleatório **x inteiro de 1 a 50 por atributo** e multiplicador de raridade, além de característica especial em itens Lendários/Celestiais. Armas são um slot oficial; seus tipos e traços estão documentados.
- A HUD planejada mantém gameplay central prioritário, equipe lateral, painéis recolhíveis e automação/log; chat e outros recursos sociais estão fora do MVP. Veja a especificação dedicada.
- A direção tecnológica aprovada separa Game Web na Vercel do servidor Supabase. O painel administrativo será um app Vercel isolado, acessível apenas a contas autorizadas.
- O MVP é uma experiência PvE individual; jogadores não compartilham o espaço de hunt. Sistemas sociais compartilhados/instanciados são pós-MVP.
- Arte de personagens e cenários será composta de sprites/PNGs estáticos feitos para o projeto; movimento e impactos serão efeitos implementados no jogo. Geração aleatória de atributos/loot é uma regra de jogo, não geração procedural de arte.

## Próximos passos

G2 segue em andamento: a migration-base passou somente no harness PGlite; falta executá-la pelo Supabase CLI e validar Data API/Auth, transações, rate limits, reconexão, segurança/Admin, backup e usabilidade com testers. Não há serviço ou interface de produção. A vertical slice (G3) começa somente após o gate G2 do [Roadmap](docs/ROADMAP.md).
