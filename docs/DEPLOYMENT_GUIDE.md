# Guia de deploy — GitHub + Vercel + Supabase

**Status: onboarding browser-first documentado; nenhuma integração/conta/projeto externo foi configurado por esta sessão.**
**Restrição atual confirmada pelo usuário:** evitar instalações. Configurar e operar Supabase, Vercel e GitHub pelo navegador (Dashboards, GitHub Integration e PR/checks); não exigir Docker, Supabase CLI ou Vercel CLI na máquina do usuário. A orientação anterior de validar primeiro via CLI/Docker local foi superada.
**Pedido atual do usuário:** iniciar o processo Supabase + Vercel. Começar por um Supabase de desenvolvimento e autorizar GitHub; a importação dos apps Vercel aguarda `apps/game-web/` e `apps/admin-web/`. Produção não será ativada neste onboarding.
**Requisito confirmado:** depois que um PR for integrado à branch `main` do GitHub, a Vercel deve publicar automaticamente a nova versão em produção, após build e verificações (não instantaneamente no merge).

Este guia separa claramente as ações que podem começar agora das que dependem de aplicações/gates. Não significa que o jogo, painel, serviços ou deploys já estejam prontos.

## 1. A ideia em uma frase

Você envia uma alteração ao GitHub; abre um PR para revisar; a Vercel cria um endereço temporário de Preview; depois que o PR é aprovado e integrado a `main`, a Vercel compila e publica a versão de produção. Se o PR também contém uma migration, o fluxo do Supabase aplica a alteração do banco por uma integração separada.

```text
mudanças do projeto → GitHub (branch/PR revisado no navegador)
                    ├── Vercel: Preview para revisar
                    └── Supabase: Preview Branch e migrations a partir do GitHub (quando configurado)

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

- `apps/game-web/` e `apps/admin-web/` ainda não existem; não há app web para importar na Vercel. O pack de sprites estático fica em `sprites/`; um subset final poderá ser servido pelo app/Vercel, sem exigir upload imediato para Supabase Storage.
- Há uma migration-base em `supabase/migrations/`, mas ela **não foi aplicada/testada** em um projeto Supabase real. Os 9 testes existentes usam PGlite e não substituem essa validação.
- Não há projeto Supabase, projeto Vercel, domínio, credenciais de deploy, integração GitHub/Vercel/Supabase ou pipeline automático configurados.
- A G2 continua aberta. O plano deste documento não fecha o gate nem inicia implementação de gameplay/Admin.

O onboarding de contas/projeto Supabase e a autorização das integrações GitHub podem começar pelo navegador. O deploy automático das aplicações Vercel não pode ser ativado até existirem apps buildáveis; produção continua bloqueada pelos gates de segurança.

### Sequência atual confirmada — tudo pelo navegador, sem instalações

O usuário definiu que não quer instalar ferramentas para usar Vercel, Supabase ou GitHub. A orientação anterior de instalar Docker/Supabase CLI e validar primeiro na máquina local está superada. A configuração abaixo usa os Dashboards e a integração GitHub do Supabase; as migrações já versionadas são executadas nos ambientes hospedados. Isso não significa que algum serviço já esteja conectado.

1. **Contas pelo navegador:** acessar GitHub, Supabase e Vercel; ativar MFA e autorizar cada integração apenas para o repositório necessário. Não compartilhar senhas, tokens ou chaves nesta conversa.
2. **Supabase dev pelo Dashboard:** criar um projeto Supabase exclusivo de desenvolvimento, por exemplo `tower-idle-adventure-dev`, com dados sintéticos. A senha do banco fica em um gerenciador de senhas. Não criar nem conectar produção nesta etapa.
3. **Conectar Supabase ↔ GitHub pelo Dashboard:** no projeto dev, abrir **Project Settings → Integrations → GitHub Integration → Authorize GitHub**, escolher `marmitero/tower-idle-adventure` e informar `.` como **Working directory**, pois `supabase/` está na raiz do repositório. Habilitar **Automatic branching** se disponível no plano para que PRs ganhem Preview Branches isoladas; confirmar custos/disponibilidade antes.
4. **Validar a migration no Preview Branch hospedado:** abrir um PR de teste pelo GitHub quando solicitado, verificar o status/comentário da integração Supabase, conferir que as migrations são aplicadas à branch de preview e inspecionar o schema no Supabase Dashboard. Preview Branch começa com schema reconstruído pelas migrations e seed, não com cópia dos dados do projeto-base; usar só dados sintéticos.
5. **Atualizar o projeto dev persistente:** só depois da prova no Preview, configurar o branch de produção da integração para que a branch `main` atualize **o projeto Supabase dev**. Se a integração mostrar a opção **Deploy to production**, lembrar que “production” nessa tela significa o projeto-base conectado: só habilitar se o projeto conectado for realmente `tower-idle-adventure-dev`. Não conectar o projeto Supabase real de produção nem habilitar esse fluxo nele agora.
6. **Testes sem instalar na sua máquina:** a prova de migration acontece no Preview Branch do Supabase. Os 9 smoke tests atuais em PGlite podem depois ser executados por GitHub Actions em runner hospedado (nada instalado no computador do usuário); esse workflow ainda não está configurado. A validação PGlite não substitui a prova no Preview Branch/Data API/Auth real.
7. **Vercel pelo navegador:** autorizar GitHub agora. Ainda não importar o repositório como Game Web/Admin: `apps/game-web/` e `apps/admin-web/` não existem. Quando existirem apps compiláveis e seguros, criar dois projetos Vercel, com essas raízes, e usar Preview em PRs com variáveis Supabase dev/staging.
8. **Produção por último:** manter projeto/banco Supabase de produção, secrets e domínio desligados até testes de Auth, RLS, Admin, backups, migrações, rollback e os gates de segurança. Depois, configurar `main` como Production Branch nos projetos Game/Admin Vercel e testar merge → checks → Production Deployment.

**Resumo:** começar no Dashboard Supabase e autorizar GitHub/Vercel sem instalar CLI/Docker. Supabase pode validar migrations em Preview Branches a partir do GitHub; Vercel pode ser autorizada agora, mas não tem apps de produção para importar ainda. O preview estático do Arena continua disponível sem instalação local.

## 4. Configuração browser-first, passo a passo

### Etapa A — preparar o GitHub

1. Manter `main` como branch de produção do produto. Trabalhar em branches curtas e abrir Pull Requests; evitar enviar alterações diretamente para `main`.
2. Configurar proteção para `main`: exigir PR aprovado; tornar obrigatórios os checks de build/testes Vercel e migration Supabase quando eles existirem e estiverem passando. Não selecionar um check ainda inexistente, pois isso pode bloquear todos os merges até o primeiro pipeline funcionar.
3. O agente desta sessão trabalha na branch `arena/01a0e5e1-tower-idle-adventure`, não em `main`. A publicação descrita aqui só começa quando alguém com permissão revisar e integrar um PR em `main`.

### Etapa B — criar ambientes Supabase separados

**Primeiro projeto a criar agora: desenvolvimento, não produção.**

1. Entre no Dashboard Supabase usando uma conta protegida com MFA; crie/seleciona uma organização e escolha **New project**. Nome sugerido: `tower-idle-adventure-dev`. O nome é uma sugestão operacional do agente, não um hostname decidido pelo usuário.
2. Selecione a região mais próxima dos jogadores de teste; confira a disponibilidade de São Paulo no Dashboard sem presumir que ela exista em todo plano. Escolha plano/limites após revisar preço e recursos.
3. Crie uma senha forte e única para o banco. Guarde-a no gerenciador de senhas; não cole em issue, commit, variável pública nem nesta conversa. Anote o `project-ref` mostrado no Dashboard, que não é senha.
4. Mantenha somente dados sintéticos nesse ambiente. Não importe contas/segredos reais e não use um projeto de produção para experimentos.
5. Depois de conectar a integração GitHub, valide primeiro a migration em Preview Branch isolada. Só então configure a integração para aplicar migrations ao projeto-base dev (passos detalhados na Etapa C). Não é necessário ligar CLI local.
6. Antes do uso por Preview, confirme que variáveis de Preview apontam para dev/staging e que não há chaves/dados de produção. Supabase Database Branching para Preview é opcional e depende do plano/disponibilidade; um projeto dev isolado é suficiente para iniciar.
7. Crie projetos remotos de **staging** e **production** separadamente apenas quando necessários. Antes de produção, confirmar plano, região, quotas, custos, backups/PITR e proteção de deploys. Nunca compartilhar o banco entre ambientes.

### Etapa C — validar e publicar migrations pelo navegador

O repositório já contém `supabase/config.toml` e a migration-base `supabase/migrations/20260928000000_g2_core_schema.sql`. Não é necessário instalar Supabase CLI, Docker ou Node.js na máquina do usuário para usar as integrações hospedadas. A integração GitHub oficial do Supabase pode reconstruir branches de preview a partir das migrations do repositório.

1. No Dashboard do projeto **dev**, abra **Project Settings → Integrations → GitHub Integration**. Autorize o GitHub, selecione `marmitero/tower-idle-adventure` e defina **Working directory** como `.` (a pasta `supabase/` fica na raiz).
2. Ative **Automatic branching** somente se estiver disponível e se o plano/custo forem aceitáveis. Quando um PR criar uma Preview Branch do Supabase, as migrations do diretório `supabase/migrations/` são aplicadas nela. Os dados do projeto-base não são copiados; use seed sintético e confira o status/comentário da integração no PR.
3. Pelo navegador do GitHub, quando estiver pronto para a prova, abra um PR de teste da branch desta sessão `arena/01a0e5e1-tower-idle-adventure` para `main` (pode ser Draft; não faça merge ainda). Verifique o comentário/status da branch Supabase e, no Dashboard dessa Preview Branch, inspecione o schema criado. A migration ainda precisa de testes dedicados de Auth, Data API, RLS e comportamento da aplicação; não concluir que 9 testes PGlite cobrem esses serviços.
4. Após aprovação do Preview, configure a branch principal da integração para atualizar o projeto-base **dev**. O botão **Deploy to production**, se usado, deve estar ligado somente ao projeto `tower-idle-adventure-dev` nesta fase: nesse contexto “production” é o alvo-base daquela integração, não a produção pública do jogo. Deixe o projeto Supabase real de produção desconectado.
5. Confirme no Dashboard que a migration esperada foi aplicada ao banco dev depois de um merge em `main`. O fluxo de migrations é separado do deployment Vercel; a ordem entre ambos não é atômica. Escreva mudanças compatíveis com app/schema anterior e novo.
6. A integração aplica migrations e itens suportados declarados, como Edge Functions/buckets. Configuração de Auth/API (URLs, providers, redirects, flags) precisa ser ajustada/verificada pelo Dashboard Supabase; não presumir que `config.toml` atualiza tudo automaticamente.
7. Se Automatic branching não estiver disponível no plano, mantenha um projeto Supabase dev separado e conecte a integração apenas a ele. Pode-se selecionar a branch de trabalho como alvo desse projeto dev para aplicar migrations hospedadas sem PR Preview isolado; deixe explícito que o alvo é compartilhado dev, confira o projeto no Dashboard e use só dados sintéticos. Para automatizar PRs sem essa função, alternativa futura é GitHub Actions em runner hospedado (sem instalação local), com secrets no navegador; isso não está configurado e exige revisão.
8. Não inserir senha, token ou chave privada em arquivos do repo, logs públicos, PR ou conversa. Configurar secrets somente no painel/secret store do serviço, se o workflow alternativo vier a ser aprovado.

**Limite atual:** nenhum projeto real conectado; esta etapa descreve o procedimento, não uma prova Supabase já executada.

### Etapa D — autorizar Vercel agora; importar os apps quando existirem

**A autorização pode começar agora; criar projetos Vercel ainda não é possível**, pois `apps/game-web/` e `apps/admin-web/` não existem e não há aplicação buildável.

1. Crie/acesse uma conta Vercel, ative MFA e autorize a integração GitHub para o repositório `marmitero/tower-idle-adventure`. Confirme acesso apenas ao repo necessário.
2. **Não importe a raiz do repo como se fosse o jogo.** Aguarde a criação e validação dos shells pelos gates de arquitetura/segurança; atualmente o repo tem docs, `sprites/`, protótipo estático e `supabase/`, não apps web.
3. Quando os diretórios estiverem implementados, no Dashboard selecione **Add New → Project**, importe o mesmo repositório duas vezes e configure:
   - projeto **Game Web** → Root Directory `apps/game-web/`;
   - projeto **Admin Web** → Root Directory `apps/admin-web/`.
4. Em cada app, confira framework preset, install/build/output commands, dependências do monorepo e defina `main` como **Production Branch**. A árvore/apps e framework final ainda precisam ser criados/testados.
5. Com integração Git ativa, branches/PRs podem gerar Vercel Previews; merge/commit em `main` inicia Production Deployment depois de build/checks. Verifique cada app via um PR de teste antes de declarar pronto; deploys são independentes.
6. Comece os Previews usando apenas variáveis e dados Supabase dev/staging. Não publique o Admin sem autenticação e autorização server-side testadas; Vercel Deployment Protection/SSO é uma camada adicional, nunca substitui a checagem de role/API.
7. Associar domínios definitivos somente após validar segurança e release. Nenhum nome/domínio final foi escolhido.

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
