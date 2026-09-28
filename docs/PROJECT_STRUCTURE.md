# Estrutura proposta do projeto

**Status:** proposta de organização; nenhum app de produção foi criado. Este documento descreve como separar responsabilidades antes de iniciar a implementação.

**Sequência atual confirmada pelo usuário:** estruturar o projeto e testar primeiro os previews locais; deixar a conexão com Vercel e os projetos Supabase remotos para uma etapa posterior. Isso não muda o requisito futuro de deploy automático na Vercel quando houver merge em `main`.

## 1. Estrutura alvo (proposta)

```text
tower-idle-adventure/
├── apps/
│   ├── game-web/             # aplicação do jogador, build/deploy separado
│   └── admin-web/            # CMS interno, build/deploy separado e protegido
├── packages/
│   └── contracts/            # tipos/schemas de payload e IDs compartilhados, sem segredos
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

A árvore é uma **proposta**, não uma decisão final de framework/gerenciador de pacotes. `game-web/` e `admin-web/` ainda não existem. O G2 continua definindo/provando detalhes técnicos; não criar pastas vazias ou arquivos de build como se fossem aplicações prontas.

## 2. Limites entre as partes

- **Game Web:** interface pública do jogador. Nunca calcula ou decide recompensas, saldo, combate ou autorização final.
- **Admin Web:** app e projeto de deploy independentes. Login, role e autorização são conferidos no servidor e em cada API; esconder um link ou proteger somente um Preview não basta.
- **`packages/contracts`:** compartilhar apenas tipos, IDs estáveis e schemas de validação de requests/responses. Não compartilhar sessões, chaves privilegiadas, lógica de autorização Admin nem componentes que façam os dois apps dependerem do mesmo bundle.
- **`supabase/`:** migrations e código confiável de backend. O cliente não recebe secret key. Funções de jogo/admin são propostas futuras, ainda não implementadas.
- **`prototypes/`:** explorações rápidas de UX. São isoladas da aplicação de produção; dados fictícios e interações demonstrativas não significam que gameplay/APIs estejam prontas.

## 3. Estratégia de preview antes da Vercel

1. **Agora:** usar `prototypes/g2-hud/index.html` em um servidor local estático para revisar navegação, hierarquia visual e responsividade. O preview não precisa de conta Vercel, Supabase, build de app nem chaves.
2. **Durante G2:** concluir a revisão local e as provas técnicas que ainda faltam. A ausência de Vercel/Supabase hospedado não equivale a um deploy nem valida Auth/API real.
3. **Depois do gate G2:** iniciar a estrutura mínima das duas aplicações, mantendo-as locais primeiro. Testar build e navegação com dados fictícios; proteger a entrada do Admin desde o primeiro shell.
4. **Quando os shells compilarem e estiverem seguros:** criar os projetos Vercel e habilitar Preview em PRs. Quando o backend remoto for necessário, criar Supabase staging isolado e apontar os Previews para dados de teste.
5. **Antes do alpha fechado:** provisionar produção e ativar o caminho completo de merge `main` → build/checks → Vercel Production Deployment, com domínio e monitoramento depois de validar o release.

## 4. O que este documento não faz

Não cria Game Web/Admin Web, APIs, gameplay, migration adicional, projeto Vercel, serviço Supabase, deploy ou credenciais. As provas locais já existentes e seus limites estão registrados em [`G2_TECHNICAL_BLUEPRINT.md`](G2_TECHNICAL_BLUEPRINT.md) e no [`Guia de deploy`](DEPLOYMENT_GUIDE.md). G2 permanece aberta até os critérios do [`Roadmap`](ROADMAP.md) serem atendidos.
