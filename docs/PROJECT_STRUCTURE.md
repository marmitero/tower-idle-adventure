# Estrutura proposta do projeto

**Status:** proposta de organização; nenhum app de produção foi criado. Este documento descreve como separar responsabilidades antes de iniciar a implementação.

**Direção atual confirmada pelo usuário:** iniciar agora o processo Supabase + Vercel, sem confundir preparação/onboarding com serviços já configurados. A prévia local continua útil; o projeto Supabase deve começar em desenvolvimento com dados sintéticos. A importação de apps na Vercel aguarda os diretórios de aplicação. Produção continua separada e protegida até os gates de segurança. A orientação anterior de adiar todas as integrações remotas foi superada.

## 1. Estrutura alvo (proposta)

```text
tower-idle-adventure/
├── apps/
│   ├── game-web/             # aplicação do jogador, build/deploy separado
│   └── admin-web/            # CMS interno, build/deploy separado e protegido
├── packages/
│   └── contracts/            # tipos/schemas de payload e IDs compartilhados, sem segredos
├── sprites/                 # pack estático inicial com avisos/licença e manifesto
├── supabase/
│   ├── migrations/           # SQL versionado; já existe uma migration-base
│   ├── functions/            # Edge Functions, quando forem autorizadas/implementadas
│   ├── tests/                # testes locais de schema e integrações
│   └── config.toml
├── prototypes/
│   └── g2-hud/               # protótipo de UX estático; não é o app do jogo
├── docs/                     # decisões, arquitetura, critérios e estado
└── README.md
```

A árvore de apps é uma **proposta**, não uma decisão final de framework/gerenciador de pacotes. `apps/game-web/` e `apps/admin-web/` ainda não existem. `sprites/` contém o pack inicial auditado; sheets de hero/mage/slime foram ligados ao protótipo estático como candidatos, não a um app de produção. O G2 continua definindo/provando detalhes técnicos; não criar pastas vazias ou arquivos de build como se fossem aplicações prontas.

## 2. Limites entre as partes

- **Game Web:** interface pública do jogador. Nunca calcula ou decide recompensas, saldo, combate ou autorização final.
- **Admin Web:** app e projeto de deploy independentes. Login, role e autorização são conferidos no servidor e em cada API; esconder um link ou proteger somente um Preview não basta.
- **`packages/contracts`:** compartilhar apenas tipos, IDs estáveis e schemas de validação de requests/responses. Não compartilhar sessões, chaves privilegiadas, lógica de autorização Admin nem componentes que façam os dois apps dependerem do mesmo bundle.
- **`supabase/`:** migrations e código confiável de backend. O cliente não recebe secret key. Funções de jogo/admin são propostas futuras, ainda não implementadas.
- **`prototypes/`:** explorações rápidas de UX. São isoladas da aplicação de produção; dados fictícios e interações demonstrativas não significam que gameplay/APIs estejam prontas.

## 3. Sequência de prévia e onboarding de serviços

1. **UX local:** continuar usando `prototypes/g2-hud/index.html` em servidor estático para hierarquia visual e responsividade. A prévia não exige conta nem chaves e não equivale a um deployment.
2. **Supabase local, em paralelo ao onboarding:** instalar Docker Desktop/runtime e Supabase CLI no ambiente do usuário; a sandbox atual não possui esses executáveis. O diretório `supabase/` e `config.toml` já existem, portanto não repetir `supabase init`. No clone, executar `supabase start` e `supabase db reset` para reaplicar a migration-base à base **local**; nunca usar `db reset --linked` como rotina.
3. **Supabase remoto de desenvolvimento:** criar um projeto separado para dev/staging, com dados sintéticos; após a prova local, vincular o CLI ao `project-ref`, revisar com `supabase db push --dry-run` e só então aplicar migrations com `supabase db push`. Nunca ligar Previews a credenciais ou dados de produção.
4. **GitHub/Vercel:** autorizar as integrações às contas/repositório agora, se desejado. A Vercel não pode importar/buildar os apps ainda, porque `apps/game-web/` e `apps/admin-web/` não existem. Depois que houver shells seguros e compiláveis, importar cada diretório raiz como projeto independente e testar Preview em PR.
5. **Produção:** manter projeto Supabase de produção, chaves de produção e domínio fora do onboarding inicial. Antes do alpha fechado, provar migrations, RLS, autorização/Admin, backups, checks e rollback; só então habilitar produção e o fluxo `main` → checks → Vercel Production Deployment.

Os detalhes operacionais e passos de interface estão em [`DEPLOYMENT_GUIDE.md`](DEPLOYMENT_GUIDE.md).

## 4. O que este documento não faz

Não cria Game Web/Admin Web, APIs, gameplay, migration adicional, projeto Vercel, serviço Supabase, deploy ou credenciais. As provas locais já existentes e seus limites estão registrados em [`G2_TECHNICAL_BLUEPRINT.md`](G2_TECHNICAL_BLUEPRINT.md) e no [`Guia de deploy`](DEPLOYMENT_GUIDE.md). G2 permanece aberta até os critérios do [`Roadmap`](ROADMAP.md) serem atendidos.
