# Tower Idle Adventure

**Tower Idle Adventure** é um RPG idle automático 2D para navegador, centrado em uma torre de andares, progressão de equipe e batalhas PvE automáticas.

> **Fase atual: G2 em andamento.** Há documentação técnica, click-through UX sem backend com três sprites candidatos, migration-base testada apenas com PGlite e pack inicial inventariado; nenhum sprite foi integrado a uma aplicação de produção. O usuário relata que criou o Supabase `tower-idle-adventure-dev` e o conectou ao GitHub na branch `main`; Automatic Branching/Preview Branch está desligado por limitação do plano e ainda não foi confirmada a aplicação da migration. A Vercel não foi configurada e não há apps de produção. O onboarding é browser-only; veja o guia passo a passo. O baseline de MVP foi decidido pelo agente sob autorização explícita do usuário e pode ser ajustado por ele; os números ainda não foram validados em playtest.

## Documentação do projeto

- [GDD — visão e regras do jogo](docs/GDD.md)
- [Escopo e decisões do MVP](docs/MVP_DECISIONS.md)
- [Especificação dos sistemas e fórmulas](docs/SYSTEMS_SPEC.md)
- [Proposta de combate e balanceamento das armas](docs/COMBAT_DESIGN.md)
- [Arquitetura visual da HUD e UX](docs/HUD_UX_SPEC.md)
- [Arquitetura técnica Vercel + Supabase](docs/TECH_ARCHITECTURE.md)
- [Guia de deploy GitHub → Vercel + Supabase](docs/DEPLOYMENT_GUIDE.md) — onboarding browser-first; Supabase dev foi criado segundo o usuário, Auto Preview fica desligado e Vercel ainda não foi configurada.
- [Estrutura proposta do projeto](docs/PROJECT_STRUCTURE.md) — separação planejada de apps, contratos, backend e protótipos; não são pastas/apps prontos.
- [Blueprint técnico detalhado do G2](docs/G2_TECHNICAL_BLUEPRINT.md)
- [Migration-base e smoke tests PostgreSQL/PGlite](supabase/migrations/20260928000000_g2_core_schema.sql) — 9 smoke tests PGlite; não equivale à validação em Supabase hospedado. Veja também [`supabase/README.md`](supabase/README.md) para limites e procedimento browser-first.
- [Threat model do MVP](docs/THREAT_MODEL.md)
- [Blueprint UX e plano de usabilidade G2](docs/G2_UX_BLUEPRINT.md)
- [Manifesto do pack de sprites e créditos/licença](sprites/ASSET_MANIFEST.md)
- [Protótipo HUD clicável (dados fictícios, três sprites candidatos, sem backend)](prototypes/g2-hud/index.html)
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
- O pack Fantasy Dungeon presente em [`sprites/`](sprites/) é a base de arte inicial; 422 PNGs válidos e avisos de origem/licença estão inventariados em [`sprites/ASSET_MANIFEST.md`](sprites/ASSET_MANIFEST.md). Sprites adicionais poderão ser criados/adicionados depois; efeitos de movimento/impacto podem ser implementados em código. Não há geração procedural de arte.

## Próximos passos

G2 segue em andamento: a migration-base passou somente no harness PGlite; falta confirmar a migration no projeto dev após merge em `main`, e testar Data API/Auth, transações, rate limits, reconexão, segurança/Admin, backup e usabilidade com testers. O usuário decidiu evitar instalações e fazer onboarding pelos navegadores. O próximo passo é confirmar no Dashboard o owner/repo conectado (o nome informado parece divergir do remoto desta sessão) e o toggle que aplica migrations no projeto dev. Auto Preview Supabase está desligado pelo plano atual. A Vercel não foi configurada; a importação aguarda `apps/game-web/` e `apps/admin-web/`. Não há serviço ou interface de produção. A vertical slice (G3) começa somente após o gate G2 do [Roadmap](docs/ROADMAP.md).
