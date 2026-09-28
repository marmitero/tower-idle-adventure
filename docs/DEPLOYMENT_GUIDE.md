# Guia de deploy — GitHub + Vercel + Supabase

**Status: onboarding passo a passo documentado; nenhuma integração/conta/projeto externo foi configurado por esta sessão.**
**Pedido atual do usuário:** iniciar já o processo Supabase + Vercel e orientar em detalhe. Iniciaremos pelo ambiente Supabase de desenvolvimento e autorização GitHub; a importação de projetos na Vercel aguarda as aplicações em `apps/game-web/` e `apps/admin-web/`. Produção não será ativada neste onboarding.
**Requisito confirmado:** depois que um PR for integrado à branch `main` do GitHub, a Vercel deve publicar automaticamente a nova versão em produção, após build e verificações (não instantaneamente no merge).

Este guia separa claramente as ações que podem começar agora das que dependem de aplicações/gates. Não significa que o jogo, painel, serviços ou deploys já estejam prontos.

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

- `apps/game-web/` e `apps/admin-web/` ainda não existem; não há app web para importar na Vercel. O pack de sprites estático fica em `sprites/`; um subset final poderá ser servido pelo app/Vercel, sem exigir upload imediato para Supabase Storage.
- Há uma migration-base em `supabase/migrations/`, mas ela **não foi aplicada** via Supabase CLI nem em um projeto Supabase real. Os 9 testes existentes usam PGlite e não substituem essa validação.
- Não há projeto Supabase, projeto Vercel, domínio, credenciais de deploy, integração GitHub/Vercel/Supabase ou pipeline automático configurados.
- A G2 continua aberta. O plano deste documento não fecha o gate nem inicia implementação de gameplay/Admin.

Portanto, neste momento não é possível ativar o deploy automático neste repositório. Primeiro as aplicações e os projetos externos precisam existir e passar pelos gates técnicos/de segurança.

### Sequência atual confirmada

O usuário mudou explicitamente a direção: **iniciar agora o processo Supabase + Vercel**. A orientação anterior de adiar todas as integrações remotas foi superada. Ainda assim, iniciar onboarding não significa abrir produção nem afirmar que algum serviço já esteja conectado.

1. **Agora — Supabase local:** instalar um runtime Docker compatível e Supabase CLI na máquina de desenvolvimento. O repo já tem `supabase/config.toml`; não rodar `supabase init` novamente. Em seguida executar `supabase start` e `supabase db reset` para validar a migration localmente. A sandbox desta sessão não tem CLI/Docker, então esta validação depende de uma máquina com as ferramentas.
2. **Agora — Supabase de desenvolvimento:** criar apenas um projeto remoto dev/staging com dados sintéticos. Após a prova local, ligar o CLI ao projeto, revisar `supabase db push --dry-run` e aplicar a migration com `supabase db push`. Não usar produção ou dados reais.
3. **Agora — contas e autorização GitHub:** criar/usar contas Supabase e Vercel, autorizar os apps GitHub para o repositório, confirmar MFA e guardar credenciais em gerenciador de senhas. Isso ainda não cria um deploy.
4. **Quando os apps existirem:** criar dois projetos Vercel com raízes `apps/game-web/` e `apps/admin-web/`, `main` como branch de produção e Preview apontado a dados de teste. Hoje essas pastas/apps não existem; importar a raiz do repositório daria um deploy vazio/inválido.
5. **Staging e produção:** testar Auth/Data API/RLS, app/Admin, migrations, backups e rollback em dev/staging. Criar um projeto Supabase de produção separado e ativar migration/deploy automático somente após os gates de segurança, antes do alpha fechado. O domínio público vem após validar release.

**Resumo:** começar Supabase dev/CLI e autorizações agora; a Vercel ainda não pode importar apps ausentes; production/deploy público permanece adiado até implementação segura. O preview local continua disponível, mas não substitui Vercel Preview.

## 4. Configuração futura, passo a passo

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
5. Depois da prova local e do `db push --dry-run`, conecte o CLI a este projeto dev e aplique migrations. Veja a Etapa C; não execute `db reset --linked` — isso apaga o banco remoto associado.
6. Antes do uso por Preview, confirme que variáveis de Preview apontam para dev/staging e que não há chaves/dados de produção. Supabase Database Branching para Preview é opcional e depende do plano/disponibilidade; um projeto dev isolado é suficiente para iniciar.
7. Crie projetos remotos de **staging** e **production** separadamente apenas quando necessários. Antes de produção, confirmar plano, região, quotas, custos, backups/PITR e proteção de deploys. Nunca compartilhar o banco entre ambientes.

### Etapa C — validar e publicar migrations com segurança

1. **Preparar a máquina local:** instalar um runtime Docker compatível (Docker Desktop é a opção mais simples) e Supabase CLI pela opção oficial correspondente ao seu sistema operacional. Se escolher instalação via npm/npx, a CLI requer Node.js 20+. Esses executáveis não estão disponíveis nesta sandbox.
2. O repositório já contém `supabase/config.toml`; **não execute `supabase init`**, pois isso tentaria criar uma configuração que já existe. Abra um terminal na raiz do clone `tower-idle-adventure/`.
3. Iniciar a stack local e reaplicar migrations do zero:

   ```bash
   supabase start
   supabase status
   supabase db reset
   npm ci --prefix supabase
   npm test --prefix supabase
   ```

   `db reset` sem `--linked` apaga/recria somente o banco Supabase local e aplica migrations/seed; o seed está desabilitado no `config.toml`. Confirme que o CLI está usando o projeto local antes de executar. Não use `db reset --linked`.
4. Se tudo passar, registrar no PR a saída/teste sem incluir senhas ou chaves. A stack local pode ser encerrada com `supabase stop`.
5. Para conectar ao projeto remoto **dev**: `supabase login` (autenticação no navegador) e depois `supabase link --project-ref <PROJECT_REF>`. Informe a senha do banco somente no prompt seguro da CLI, não como argumento de comando. Confira no Dashboard que o project-ref é o projeto `tower-idle-adventure-dev`, não produção.
6. Primeiro só simule o que será aplicado: `supabase db push --dry-run`. Revise a lista/SQL; se apontar ao projeto dev correto e for esperado, então `supabase db push` aplica as migrations pendentes **nesse banco remoto**. Não executar contra produção neste início. O comando não substitui teste de RLS/Auth/Data API.
7. Depois da primeira prova manual, no Dashboard do projeto dev, abra a integração GitHub, autorize o app Supabase no repositório `marmitero/tower-idle-adventure` e escolha `main` como a branch que atualiza **este banco dev**. Configure `.` como Working Directory (a raiz que contém `supabase/`). Se o plano oferecer Database Branching/Preview branches, use-as somente com dados sintéticos e teste em um PR. Não conecte nem habilite deploy de um banco de produção neste onboarding.
8. O Supabase pode executar migrations no fluxo Git conectado e também publicar itens suportados configurados, como Edge Functions/buckets; Auth/API e outros settings não são aplicados automaticamente por padrão. URLs de redirecionamento e flags de Auth em `config.toml` exigem configuração/validação explícita nos projetos reais.
9. Se GitHub integration/branching não estiver disponível/adequada ao plano, use CI com Supabase CLI e segredos guardados no secret store do GitHub. Nunca inserir senha, token ou chave privada em código, PR, log ou conversa.

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
- [Supabase — CLI e desenvolvimento local](https://supabase.com/docs/guides/local-development/cli/getting-started)
- [Supabase — fluxo local, link e db push](https://supabase.com/docs/guides/local-development/cli-workflows)
