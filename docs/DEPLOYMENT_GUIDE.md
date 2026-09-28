# Guia de deploy — GitHub + Vercel + Supabase

**Status: plano documentado; integração ainda não configurada.**
**Requisito confirmado pelo usuário:** depois que um PR for integrado à branch `main` do GitHub, a Vercel deve publicar automaticamente a nova versão em produção. O deploy só fica disponível depois do build e das verificações; não acontece no mesmo milissegundo do merge.

Este guia explica a configuração futura em linguagem simples. Ele não significa que o jogo, o painel, serviços ou deploys já estejam prontos.

## 1. A ideia em uma frase

Você envia uma alteração ao GitHub; abre um PR para revisar; a Vercel cria um endereço temporário de Preview; depois que o PR é aprovado e integrado a `main`, a Vercel compila e publica a versão de produção. Se o PR também contém uma migration, o fluxo do Supabase aplica a alteração do banco por uma integração separada.

```text
computador → branch/PR no GitHub
                    ├── Vercel: Preview para revisar
                    └── Supabase: validação/ambiente de preview para migrations (quando configurado)

PR aprovado + merge em main
                    ├── Vercel: build → Production Deployment → domínio de produção
                    └── Supabase: aplica migrations, se a integração de banco estiver configurada
```

**“Em tempo real”** aqui significa “automaticamente, sem alguém apertar um botão de publicar depois do merge”. Primeiro ainda há build e verificações, então normalmente existe um intervalo de minutos. Se o build falhar, a nova versão não deve ser considerada publicada; o deployment anterior continua sendo a referência de produção.

## 2. O que cada serviço faz

- **GitHub:** guarda o código, as migrations e o histórico; PRs permitem revisar antes de integrar.
- **Vercel:** compila e hospeda as aplicações web. Com o repositório Git conectado, commits em branches/PRs podem gerar Previews; commits na branch de produção (`main`) geram Production Deployments. Um Preview não é a versão ao vivo.
- **Supabase:** fornece banco PostgreSQL, autenticação e outros serviços de backend. As mudanças estruturais do banco são arquivos SQL chamados **migrations**. A Vercel não aplica essas migrations por conta própria.

A Vercel e o Supabase observam o mesmo merge, mas são dois deploys independentes. O GitHub pode mostrar o status de cada um. É importante escrever migrations compatíveis com a versão antiga e a nova do app, porque não se deve depender de qual dos dois termina primeiro.

## 3. Situação real deste repositório hoje

Até 28/09/2026:

- `game-web/` e `admin-web/` ainda não existem; não há app web para importar na Vercel.
- Há uma migration-base em `supabase/migrations/`, mas ela **não foi aplicada** via Supabase CLI nem em um projeto Supabase real. Os 9 testes existentes usam PGlite e não substituem essa validação.
- Não há projeto Supabase, projeto Vercel, domínio, credenciais de deploy, integração GitHub/Vercel/Supabase ou pipeline automático configurados.
- A G2 continua aberta. O plano deste documento não fecha o gate nem inicia implementação de gameplay/Admin.

Portanto, neste momento não é possível ativar o deploy automático neste repositório. Primeiro as aplicações e os projetos externos precisam existir e passar pelos gates técnicos/de segurança.

### Sequência que vamos seguir

O usuário orientou deixar as integrações Vercel/Supabase para mais adiante, estruturar o projeto e testar os previews primeiro. Vou interpretar **“previews” agora como a prévia local estática de UX**, sem conta ou deploy na Vercel; ela não equivale a um Vercel Preview Deployment nem valida o backend.

1. **Agora:** documentar a estrutura proposta e abrir a prévia local existente `prototypes/g2-hud/index.html` para revisão. Não configurar Vercel, projeto Supabase remoto ou produção nesta etapa.
2. **Depois da revisão do preview:** retomar as provas restantes de G2, incluindo Supabase CLI + Docker local para validar migrations. Isso ainda não cria nem conecta um projeto Supabase hospedado.
3. **Após G2, quando existir um esqueleto de Game Web/Admin que compile e esteja seguro:** conectar os apps à Vercel/GitHub e começar os Vercel Previews de PR. Não é preciso esperar o jogo completo, mas o Admin deve ter verificação server-side antes de disponibilizar seu endereço.
4. **Quando o backend precisar de Auth/API remotos:** criar um Supabase de staging separado, com dados sintéticos; Previews nunca usam credenciais ou dados de produção.
5. **Antes do alpha fechado:** criar o ambiente Supabase de produção, revisar migrations/RLS/segredos/backups, proteger `main` e habilitar o fluxo de merge em `main` → build/checks → Production Deployment Vercel. Associar o domínio público depois de validar o release.

**Resumo:** preview local primeiro; provas G2 depois; integrações de Preview/staging quando houver apps seguros; produção por último. Assim podemos revisar a interface sem iniciar cedo demais serviços externos, mas também não deixamos a integração para quando o jogo inteiro estiver pronto.

## 4. Configuração futura, passo a passo

### Etapa A — preparar o GitHub

1. Manter `main` como branch de produção do produto. Trabalhar em branches curtas e abrir Pull Requests; evitar enviar alterações diretamente para `main`.
2. Configurar uma regra de proteção para `main`: exigir PR aprovado e os checks importantes (build/testes da Vercel e validação de migration do Supabase, quando ativada). Assim um erro detectado não entra silenciosamente na branch de produção.
3. O agente desta sessão trabalha na branch `arena/01a0e5e1-tower-idle-adventure`, não em `main`. A publicação descrita aqui só começa quando alguém com permissão revisar e integrar um PR em `main`.

### Etapa B — criar ambientes Supabase separados

1. Criar a organização e os projetos Supabase quando chegar a hora de provisionar a infraestrutura. Nunca usar o mesmo banco para testes e produção.
2. Manter dados sintéticos no desenvolvimento e staging. O projeto de produção recebe apenas dados reais e não deve ser usado para experimentar.
3. A arquitetura planejada separa **dev**, **staging** e **production**. Para Previews, usar um banco isolado de testes (ou branches de banco Supabase se o recurso estiver disponível no plano). Não colocar chaves nem dados de produção em Preview.
4. Confirmar plano, região, limites e custos antes de habilitar recursos que dependam de plano, incluindo branching, backups/PITR e proteção de deployments.

### Etapa C — versionar e revisar migrations

1. Toda alteração de schema vai como um novo arquivo SQL em `supabase/migrations/`; não editar manualmente o banco de produção pelo Dashboard como método normal de mudança.
2. Revisar o SQL no PR. Antes de produção, aplicar e testar do zero com Supabase CLI local e em staging; verificar RLS, grants, autenticação e comportamento da aplicação.
3. O seed atual está desabilitado (`supabase/config.toml`). Não carregar dados de demonstração ou usuários de teste em produção.
4. A integração GitHub do Supabase, quando habilitada, deve apontar para a raiz que contém `supabase/` (neste repositório, a raiz do repo) e ter `main` como branch de produção. Configurar os Previews/checks e ativar o deploy de produção somente depois de testar o fluxo em staging.
5. O Supabase documenta deploy automático de migrations no merge para a branch de produção. A integração também pode publicar Edge Functions e buckets declarados na configuração; outras configurações, como Auth/API, não são automaticamente aplicadas por padrão. Neste repo, URLs de redirecionamento e flags de Auth em `config.toml` ainda precisam de configuração/validação explícita nos projetos reais.
6. Se o recurso de integração/branching não estiver disponível ou adequado ao plano, a alternativa é um workflow de CI com Supabase CLI e segredos guardados nas configurações do GitHub. Nunca colocar token, senha ou chave privada no código, no PR ou nesta conversa.

### Etapa D — conectar as aplicações à Vercel

Quando os diretórios e aplicações estiverem implementados:

1. Criar uma conta/equipe Vercel e autorizar o aplicativo GitHub da Vercel para este repositório.
2. Importar o mesmo repositório como **dois projetos Vercel**, cada um com seu diretório raiz:
   - projeto **Game Web** → `game-web/`;
   - projeto **Admin Web** → `admin-web/`.
3. Em cada projeto, conferir o framework/comando de build detectado e definir explicitamente `main` como **Production Branch**.
4. Com a integração Git ativa, commits em branches de trabalho/PRs geram Previews; o merge/novo commit em `main` inicia um Production Deployment de cada projeto afetado. Configure o root directory e confirme isso usando um PR de teste antes de considerar pronto.
5. Não expor o Admin Web antes de implementar e testar autorização no servidor. A proteção de Preview da Vercel é uma camada adicional; ela não substitui login, verificação de role e proteção de cada endpoint administrativo na aplicação/Supabase.
6. Só associar os domínios definitivos (por exemplo, um domínio do jogo e outro do Admin) quando os projetos estiverem seguros e validados. Os nomes/domínios finais ainda não foram escolhidos.

### Etapa E — preencher variáveis por ambiente

Na área de configurações de cada projeto Vercel, cadastrar variáveis de forma separada para **Development**, **Preview** e **Production**. Uma mudança de variável vale para deployments novos; se a variável mudar, será necessário gerar um novo deployment.

Exemplo futuro para app Next.js/Supabase:

```text
NEXT_PUBLIC_SUPABASE_URL=https://<projeto-do-ambiente>.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

- `NEXT_PUBLIC_*` é incluído no código enviado ao navegador. A **publishable key** é própria para o cliente, mas só é segura com RLS/grants corretos; não é uma senha.
- Uma chave privilegiada (`SUPABASE_SECRET_KEY`, ou a antiga `service_role`) só pode existir em código executado no servidor e nunca pode ter prefixo `NEXT_PUBLIC_`, ir para o browser, logs ou repositório. Essa chave pode ignorar RLS.
- Valores de Preview apontam para dev/staging; valores de Production apontam para o Supabase exclusivo de produção. Nunca reutilizar a chave privilegiada de produção em PRs/Previews.
- Arquivos locais `.env.local` não devem ser commitados. Segredos de produção são adicionados diretamente no painel do provedor/secret store adequado.

### Etapa F — provar o fluxo antes de chamar de pronto

1. Abrir um PR pequeno em uma branch que não seja `main`.
2. Confirmar no GitHub que a Vercel criou um Preview para Game Web/Admin Web, e que o Preview usa apenas variáveis e dados de teste.
3. Confirmar os checks de build, testes e migration; testar login, autorização do Admin e principais rotas, não apenas se a página abre.
4. Confirmar que um jogador comum não consegue ver dados administrativos nem chamar APIs administrativas diretamente.
5. Depois da aprovação, integrar o PR em `main`.
6. Verificar na Vercel o novo Production Deployment, estado `Ready`, logs de build e domínio esperado. Verificar separadamente no Supabase se as migrations esperadas foram aplicadas e se as verificações passaram.
7. Anotar o resultado/data e não declarar o pipeline ativo antes deste teste completo.

## 5. Como trabalhar depois da configuração

Para cada alteração, o fluxo normal fica assim:

1. Criar uma branch a partir da `main` atualizada.
2. Fazer uma mudança pequena; incluir testes e, se houver mudança de banco, a migration correspondente.
3. Abrir PR para `main` e esperar a Vercel gerar o Preview.
4. Revisar o Preview e os checks; corrigir falhas no mesmo PR.
5. Aprovar e fazer merge.
6. A Vercel constrói e publica automaticamente os projetos web em produção. Se as migrations do Supabase estiverem automatizadas, o Supabase aplica as alterações do banco em seu fluxo próprio.
7. Conferir os dois resultados e monitorar erros após a publicação.

Um PR não precisa ser publicado manualmente pela Vercel. Se o build/teste falhar, corrigir o PR antes de fazer merge. Uma mudança nas variáveis ou configurações de projeto pode exigir um novo deployment.

## 6. Ordem segura para mudanças de banco

Deploy de aplicação e deploy de schema não são uma operação atômica. Ambos podem iniciar após o merge e terminar em ordem diferente. Para evitar quebrar a versão ao vivo, usar a estratégia **expandir → migrar app → limpar**:

1. **Expandir:** adicionar coluna/tabela nova sem remover a antiga, com defaults compatíveis e permissões revisadas.
2. **Migrar o app:** fazer a nova versão funcionar com o schema antigo e o novo, ou separar em PRs para garantir que o schema aditivo já esteja pronto antes da feature.
3. **Observar:** conferir métricas, dados e versão implantada.
4. **Limpar depois:** remover coluna/estrutura antiga em outro PR, somente quando nenhum deployment ativo precisar dela.

Não combinar uma remoção destrutiva de coluna com o primeiro deploy do app que deixa de usá-la. Não rodar uma migration de rollback às cegas; correções de banco normalmente exigem uma migration nova, backup e um plano próprio.

## 7. Como desfazer uma publicação

- **Aplicação web:** em caso de problema, usar o deployment anterior da Vercel ou reverter o commit/PR e deixar a Vercel publicar a correção. Confirmar o domínio e observar logs.
- **Banco:** rollback de código não desfaz automaticamente uma migration. Preservar dados; avaliar migration corretiva para frente ou restauração de backup com responsável técnico. Testar o procedimento em staging antes de depender dele.
- Vercel rollback e recuperação de banco são ações distintas; ter um deployment anterior não significa que o banco voltou no tempo.

## 8. Checklist antes de ativar em produção

- [ ] Aplicações Game Web e Admin Web implementadas, builds e testes passando.
- [ ] Projeto Vercel separado para cada app, com diretórios raiz corretos e production branch `main`.
- [ ] Autorização server-side do Admin testada; previews protegidos e produção não expõe APIs/dados administrativos a jogadores.
- [ ] Projetos Supabase separados; migrations testadas por CLI em local/staging; RLS/grants revisados.
- [ ] Variáveis Preview usam apenas banco de teste; secrets de produção não chegam ao browser nem a Preview.
- [ ] Checks requeridos no GitHub; Preview validado; merge teste em `main` produziu deployment `Ready`.
- [ ] Migrations de produção verificadas separadamente; ordem/compatibilidade entre schema e aplicação documentadas.
- [ ] Domínio, monitoramento, backup e plano de recuperação verificados.

## Referências oficiais

- [Vercel — Git deployments](https://vercel.com/docs/git)
- [Vercel — Monorepos](https://vercel.com/docs/monorepos)
- [Vercel — Ambientes de deployment](https://vercel.com/docs/deployments/environments)
- [Vercel — Variáveis de ambiente](https://vercel.com/docs/environment-variables)
- [Supabase — GitHub integration/branching](https://supabase.com/docs/guides/deployment/branching/github-integration)
- [Supabase — Database migrations](https://supabase.com/docs/guides/deployment/database-migrations)
- [Supabase — API keys (publishable vs. secret)](https://supabase.com/docs/guides/getting-started/api-keys)
