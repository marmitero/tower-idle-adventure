# Guia de deploy — GitHub + Vercel + Supabase

**Status: onboarding browser-first parcial; estado informado pelo usuário em 28/09/2026.** O usuário criou o Supabase `tower-idle-adventure-dev` e relata que o conectou a um repositório GitHub na branch `main`; não verificamos o Dashboard nesta sessão nem confirmamos aplicação de migration. Preview Branch/Automatic Branching do Supabase não está disponível no plano atual e ficará desabilitado. Vercel ainda não foi configurada.
**Restrição confirmada:** evitar instalações. Configurar e operar Supabase, Vercel e GitHub pelo navegador; não exigir Docker, Supabase CLI ou Vercel CLI na máquina do usuário. As orientações anteriores de CLI/Docker e Preview Branch automático foram superadas.
**Atenção ao nome do repositório:** o checkout desta sessão usa `marmitero/tower-idle-adventure`; o usuário descreveu a conexão como `idle-tower-adventure`. Confirmar o nome completo owner/repo no Dashboard Supabase antes de permitir que migrations sejam aplicadas.
**Requisito confirmado:** merge em `main` deve iniciar deploy de produção Vercel após build/checks, mas isso não está configurado e os apps `apps/game-web/`/`apps/admin-web/` ainda não existem.
**Requisito confirmado:** depois que um PR for integrado à branch `main` do GitHub, a Vercel deve publicar automaticamente a nova versão em produção, após build e verificações (não instantaneamente no merge).

Este guia separa claramente as ações que podem começar agora das que dependem de aplicações/gates. Não significa que o jogo, painel, serviços ou deploys já estejam prontos.

## 1. A ideia em uma frase

Você envia uma alteração ao GitHub; abre um PR para revisar; a Vercel cria um endereço temporário de Preview; depois que o PR é aprovado e integrado a `main`, a Vercel compila e publica a versão de produção. Se o PR também contém uma migration, o fluxo do Supabase aplica a alteração do banco por uma integração separada.

```text
Fluxo-alvo quando os apps existirem:
branch/PR → Vercel Preview (futuro)
          └── Supabase: sem DB Preview por PR no plano atual; revisar migration no PR

PR aprovado + merge em main
                    ├── Vercel: build → Production Deployment (ainda não configurado)
                    └── Supabase dev: aplicar migrations se Deploy to production estiver ativo
```

A integração Supabase/branch e o toggle de deploy ainda precisam de confirmação no Dashboard; não declarar migration aplicada antes de ver o histórico.

**“Em tempo real”** aqui significa “automaticamente, sem alguém apertar um botão de publicar depois do merge”. Primeiro ainda há build e verificações, então normalmente existe um intervalo de minutos. Se o build falhar, a nova versão não deve ser considerada publicada; o deployment anterior continua sendo a referência de produção.

## 2. O que cada serviço faz

- **GitHub:** guarda o código, as migrations e o histórico; PRs permitem revisar antes de integrar.
- **Vercel:** compila e hospeda as aplicações web. Com o repositório Git conectado, commits em branches/PRs podem gerar Previews; commits na branch de produção (`main`) geram Production Deployments. Um Preview não é a versão ao vivo.
- **Supabase:** fornece banco PostgreSQL, autenticação e outros serviços de backend. As mudanças estruturais do banco são arquivos SQL chamados **migrations**. A Vercel não aplica essas migrations por conta própria.

A Vercel e o Supabase observam o mesmo merge, mas são dois deploys independentes. O GitHub pode mostrar o status de cada um. É importante escrever migrations compatíveis com a versão antiga e a nova do app, porque não se deve depender de qual dos dois termina primeiro.

## 3. Situação real deste repositório hoje

Até 28/09/2026, segundo o estado do repositório e o relato do usuário:

- `apps/game-web/` e `apps/admin-web/` ainda não existem; não há app web para importar na Vercel. O pack de sprites estático fica em `sprites/`; um subset final poderá ser servido pelo app/Vercel, sem exigir upload imediato para Supabase Storage.
- O usuário relata ter criado `tower-idle-adventure-dev` e ligado a uma branch `main` de um repositório GitHub. A migration-base existe em `supabase/migrations/`, mas **não há confirmação de que tenha sido aplicada**. Os 9 testes existentes usam PGlite e não substituem validação Supabase.
- O nome que o usuário informou (`idle-tower-adventure`) não coincide literalmente com o remoto desta sessão (`marmitero/tower-idle-adventure`); validar owner/repo no Dashboard antes de aplicar migrations.
- Supabase Automatic Branching/Preview Branches está desligado por indisponibilidade no plano atual, conforme usuário. Vercel ainda não foi configurada; não há projetos Vercel, domínio ou deploy.
- A G2 continua aberta. O projeto dev informado não fecha o gate nem inicia implementação de gameplay/Admin.

O usuário já iniciou o onboarding ao criar o projeto Supabase dev e conectá-lo à branch `main`. Próxima verificação é o nome completo do repositório e a opção que aplica migrations ao projeto-base. A Vercel continua sem configuração; deploy de app aguarda aplicações buildáveis e os gates de segurança.

### Sequência atual confirmada — tudo pelo navegador, sem instalações

O usuário definiu que não quer instalar ferramentas para usar Vercel, Supabase ou GitHub. O caminho é operar nos Dashboards e na integração GitHub do Supabase; não instalar Docker/Supabase CLI/Vercel CLI.

1. **Confirmar o vínculo informado:** no Dashboard do projeto `tower-idle-adventure-dev`, conferir o owner/nome completo do repositório, a branch `main` e Working Directory `.`. O remoto desta sessão é `marmitero/tower-idle-adventure`; o usuário descreveu o nome como `idle-tower-adventure`. Se o slug completo não for o esperado, pausar antes de habilitar aplicação automática de migrations.
2. **Preview branches:** manter Automatic Branching/Auto Preview desabilitado, conforme a restrição do plano atual. Não haverá uma base de banco isolada para cada PR; os valores/revisões do PR devem ser verificados no GitHub antes do merge.
3. **Aplicação ao projeto dev:** confirmar no Dashboard se **Deploy to production** está ativo para a integração. Esse toggle, se habilitado, só pode apontar para `tower-idle-adventure-dev` nesta fase; no Supabase ele publica as migrations da branch conectada no projeto-base. Se estiver desligado, o vínculo ao repositório não basta para presumir que migrations serão aplicadas após merge. Não ativar em um projeto Supabase de produção.
4. **Após merge em `main`:** verificar no Dashboard Supabase o histórico/status das migrations e o schema esperado. Isso valida a aplicação no banco dev, mas não oferece teste pré-merge isolado nem substitui a revisão de RLS/Auth/Data API. O seed atual está desabilitado; usar somente dados sintéticos.
5. **Sem instalação local:** os 9 smoke tests PGlite já foram executados pelo agente anteriormente, mas não estão configurados como GitHub Actions. Se desejado, podemos acrescentar um workflow hospedado que os execute a cada PR; nenhuma dependência seria instalada no computador do usuário. Isso não substitui a prova do banco Supabase.
6. **Vercel:** ainda não foi configurada. Pode-se autorizar a integração GitHub pelo navegador, mas não importar como Game Web/Admin enquanto `apps/game-web/` e `apps/admin-web/` não existirem. Quando houver apps seguros/buildáveis, importar cada raiz e configurar Previews/Production no Dashboard.
7. **Produção:** manter o projeto/banco Supabase de produção, secrets e domínio separados até testes de Auth, RLS, Admin, backups, migrations e rollback. O merge em `main` só deve aplicar automaticamente à produção depois dos gates de segurança e de um projeto Vercel válido.

**Resumo atual:** Supabase dev existe segundo o usuário e está ligado a `main`; o Auto Preview de Supabase fica desligado por limitação do plano. Falta confirmar o slug exato e o estado do toggle Deploy to production. Vercel segue sem configuração e sem apps para importar.

## 4. Configuração browser-first, passo a passo

### Etapa A — preparar o GitHub

1. Manter `main` como branch de produção do produto. Trabalhar em branches curtas e abrir Pull Requests; evitar enviar alterações diretamente para `main`.
2. Configurar proteção para `main`: exigir PR aprovado; tornar obrigatórios os checks de build/testes Vercel e migration Supabase quando eles existirem e estiverem passando. Não selecionar um check ainda inexistente, pois isso pode bloquear todos os merges até o primeiro pipeline funcionar.
3. O agente desta sessão trabalha na branch `arena/01a0e5e1-tower-idle-adventure`, não em `main`. A publicação descrita aqui só começa quando alguém com permissão revisar e integrar um PR em `main`.

### Etapa B — revisar o projeto Supabase dev já criado

**O usuário informa que `tower-idle-adventure-dev` já existe e está conectado à branch `main`; não criar outro projeto agora.**

1. No Dashboard, conferir o nome e `project-ref` do projeto, região, plano e limites; confirmar que este é o projeto de desenvolvimento, não produção.
2. Confirmar que os dados são sintéticos e que a senha do banco está guardada em um gerenciador de senhas. Não pedir nem colar a senha em chat, issue, commit ou variável pública.
3. Conferir o nome completo do repositório conectado e a branch `main`; `supabase/` está na raiz do repo esperado desta sessão, portanto o Working Directory deve ser `.`. Há uma diferença aparente entre o nome informado pelo usuário (`idle-tower-adventure`) e o remoto do checkout (`marmitero/tower-idle-adventure`); corrigir o vínculo antes de ativar deploy se forem projetos distintos.
4. Automatic Branching/Preview Branch está indisponível no plano atual e permanece desligado, conforme usuário. Não pagar upgrade nem habilitar uma Preview Branch automática nesta etapa.
5. Conferir o estado do toggle **Deploy to production**. Se o objetivo é aplicar migrations da `main` ao projeto dev após merge, habilitar somente após confirmar o projeto/ref e o repositório corretos. Não ligar esse toggle em eventual banco de produção.
6. Staging e production continuam separados e podem ser criados posteriormente, depois de definir custos, backups/PITR, Auth/RLS, integração e gates de segurança.

### Etapa C — validar e publicar migrations pelo navegador

O repositório contém `supabase/config.toml` e a migration-base `supabase/migrations/20260928000000_g2_core_schema.sql`. Não é necessário instalar Supabase CLI, Docker ou Node.js na máquina do usuário. Automatic Branching está desligado por indisponibilidade no plano atual, conforme relato do usuário.

1. No Dashboard do Supabase `tower-idle-adventure-dev`, conferir o nome completo do repo conectado. O remote deste checkout é `marmitero/tower-idle-adventure`; se o nome exibido como `idle-tower-adventure` apontar para outro repo, interromper antes de aplicar migrations.
2. Confirmar Working directory `.` e branch conectada `main`. O objetivo relatado pelo usuário é que o banco dev receba mudanças apenas após merge em `main`.
3. Conferir **Deploy to production** no GitHub Integration. Para que migrations sejam aplicadas ao projeto-base dev após merge, o toggle deve estar habilitado nesse projeto dev; confirmar nome/project-ref antes. Se desligado, não presumir que só conectar o repo aplica migrations automaticamente.
4. Como não há Preview Branch isolada, revisar o arquivo SQL pelo diff/PR no GitHub antes do merge. Não existe prova hospedada pré-merge neste plano; os smoke tests PGlite (9/9 em execução anterior do agente) são evidência auxiliar, não substituto para o Supabase.
5. Depois de um merge em `main`, abrir o Supabase Dashboard e confirmar a migração no histórico/status e o schema esperado em **Database**. Essa é uma mudança no ambiente compartilhado dev, não uma aprovação de produção. Usar somente dados sintéticos; a migration não foi confirmada como aplicada até esse teste.
6. O fluxo Git pode executar migrations e itens suportados declarados. Configurações de Auth/API (URLs, providers, redirects, flags) precisam ser ajustadas/verificadas pelo Dashboard; não presumir que `config.toml` atualiza tudo automaticamente.
7. Se mais tarde for necessário validar antes de `main` sem Pro, opções browser-first são criar um segundo projeto dev de teste conectado a uma branch específica pelo Dashboard (se o plano permitir) ou configurar GitHub Actions em runner hospedado. Não habilitar Preview Branch automático nem fazer upgrade sem nova decisão.
8. Não inserir senha, token ou chave privada em arquivos do repo, logs públicos, PR ou conversa. Nenhuma credencial deve ser enviada aqui.

**Limite atual:** projeto e integração foram reportados pelo usuário, mas não foram verificados pelo agente; migration aplicada ainda não confirmada. Automatic Branching/Preview Branch por PR está desabilitado.

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

1. Quando houver apps e pipeline, abrir um PR pequeno em uma branch que não seja `main`.
2. Vercel Previews para Game Web/Admin só serão verificáveis depois da configuração Vercel e da criação dos apps; esse serviço ainda não foi configurado.
3. Para migrations, revisar SQL e checks do PR. O plano Supabase atual não fornece Preview Branch isolada; antes do merge não haverá banco remoto efêmero para testar o SQL.
4. Validar login, autorização do Admin e principais rotas quando os apps existirem; confirmar que um jogador comum não vê dados administrativos nem chama suas APIs.
5. Após revisão/aprovação e confirmação do repo/branch conectados, integrar o PR em `main`.
6. Depois do merge, verificar no Dashboard Supabase se migration/status/schema esperados aparecem no projeto dev (somente se o toggle de deploy estiver ativo). Quando a Vercel estiver configurada, verificar também o Production Deployment e logs; são fluxos independentes.
7. Anotar o resultado/data e não declarar o pipeline ativo antes deste teste completo.

## 5. Como trabalhar depois da configuração

Para cada alteração, o fluxo-alvo depois de implementar/configurar os apps fica assim:

1. Criar uma branch a partir da `main` atualizada.
2. Fazer uma mudança pequena; incluir testes e, se houver mudança de banco, a migration correspondente.
3. Abrir PR para `main`. Vercel Preview só surgirá após configuração futura; Supabase Preview Branch não está habilitado no plano atual.
4. Revisar diff/SQL e checks disponíveis no PR; corrigir falhas antes do merge. Não supor teste de migration em banco isolado.
5. Aprovar e fazer merge.
6. A integração Supabase deve aplicar migrations ao projeto dev somente se `Deploy to production` estiver habilitado no projeto correto; confirmar no Dashboard. Vercel só publicará apps em produção após ser configurada e quando os diretórios existirem.
7. Conferir resultados separadamente e monitorar erros após publicação.

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
