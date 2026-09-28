# Tower Idle Adventure

**Tower Idle Adventure** é um RPG idle automático 2D para navegador, centrado em uma torre de andares, progressão de equipe e batalhas PvE automáticas.

> **Fase atual: documentação e pré-produção.** Ainda não há jogo implementado. Conforme a diretriz do projeto, decisões de design, regras e plano de produção serão documentados e aprovados antes de começar a implementação.

## Documentação do projeto

- [GDD — visão e regras do jogo](docs/GDD.md)
- [Especificação dos sistemas e fórmulas](docs/SYSTEMS_SPEC.md)
- [Proposta de combate e balanceamento das armas](docs/COMBAT_DESIGN.md)
- [Arquitetura visual da HUD e UX](docs/HUD_UX_SPEC.md)
- [Arquitetura técnica Vercel + Supabase](docs/TECH_ARCHITECTURE.md)
- [Painel administrativo de conteúdo](docs/ADMIN_PANEL_SPEC.md)
- [AI_State — estado e passagem de contexto entre etapas](docs/AI_STATE.md)
- [Roadmap — etapas até lançamento e divulgação](docs/ROADMAP.md)

## Princípios já definidos

- O jogador controla uma equipe de até três personagens; as lutas e a seleção de alvos/turnos são automáticas.
- A progressão na torre é manual por padrão. A subida automática de andares é um benefício VIP opcional.
- Equipamentos usam atributos-base, multiplicador aleatório **x inteiro de 1 a 50 por atributo** e multiplicador de raridade, além de característica especial em itens Lendários/Celestiais. Armas são um slot oficial; seus tipos e traços estão documentados.
- A proposta de HUD mantém perfil/equipe à esquerda, navegação no topo, combate no centro, automação no topo direito, log e chat embaixo; veja a especificação dedicada.
- A direção tecnológica aprovada separa Game Web na Vercel do servidor Supabase. O painel administrativo será um app Vercel isolado, acessível apenas a contas autorizadas.
- O mundo social é assíncrono: jogadores não ocupam nem alteram o espaço de exploração uns dos outros; interagem em sistemas compartilhados ou instanciados.
- Arte de personagens e cenários será composta de sprites/PNGs estáticos feitos para o projeto; movimento e impactos serão efeitos implementados no jogo. Geração aleatória de atributos/loot é uma regra de jogo, não geração procedural de arte.

## Próxima etapa

Revisar e fechar as decisões em aberto registradas nos documentos. A implementação só deve começar após o marco de aprovação de design e escopo no roadmap.
