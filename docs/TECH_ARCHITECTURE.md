# Arquitetura técnica — Vercel + Supabase

**Versão:** 0.1 — direção tecnológica aprovada
**Decisão confirmada pelo usuário:** usar **Vercel + Supabase**, separando o cliente do jogo do servidor.
**Estado:** arquitetura proposta para detalhamento técnico; nenhuma infraestrutura/código foi implementado.

## 1. Separação de responsabilidades

- **Vercel — cliente:** hospeda o jogo web (interface, renderização 2D, efeitos visuais em código) e entrega arquivos estáticos/PNGs. O cliente envia intenções e apresenta respostas; não é autoridade de combate, loot, progresso ou moedas.
- **Supabase — servidor/plataforma de backend:** Supabase Auth, PostgreSQL, Edge Functions como API confiável, Storage para assets/conteúdo e Realtime apenas para notificações/sistemas adequados.
- **Admin Panel — aplicação separada:** painel interno publicado em projeto/domínio Vercel distinto do cliente de jogadores, protegido na borda por Deployment Protection/SSO se disponível ou middleware autenticado equivalente, e conectado a endpoints administrativos protegidos no Supabase. Não existe link de entrada no jogo.

```text
Jogador → Game Web (Vercel) → HTTPS/JWT → Edge Functions (Supabase)
                                      ├── PostgreSQL (RLS / estado autoritativo)
                                      ├── Storage (PNGs e arquivos de conteúdo)
                                      └── Realtime (eventos autorizados/notificações)

Admin autorizado → Admin Web (Vercel isolado) → HTTPS/JWT → Admin Edge Functions
                                                      ├── valida role/admin
                                                      ├── grava rascunhos/auditoria
                                                      └── publica versão de conteúdo → PostgreSQL/Storage

Jogador comum ──X── Admin Web / APIs administrativas
```

A separação do cliente e servidor é uma fronteira de segurança, não apenas uma separação de diretórios. O jogo pode ser servido publicamente; decisões com impacto em estado/economia são validadas e gravadas do lado Supabase.

## 2. Aplicações e ambientes

Estrutura sugerida para o repositório/entregas (nomes ajustáveis na etapa técnica):

- `game-web`: cliente do jogo, projeto Vercel próprio.
- `admin-web`: CMS/painel administrativo, outro projeto Vercel e domínio restrito por autenticação.
- `supabase/`: migrations SQL, políticas RLS, Edge Functions, tipos e seeds de desenvolvimento.

Ambientes **dev**, **staging** e **production** devem ter projetos/configurações Supabase e Vercel isolados. Preview deployments não podem receber segredo de produção nem publicar conteúdo real. Migrações de schema são versionadas e revisadas; dados de conteúdo são editados pelo painel, sem código.

## 3. Contrato cliente-servidor

### Game Web → Supabase

1. O cliente autentica por Supabase Auth e obtém sessão/JWT.
2. Catálogo publicado (itens, personagens, inimigos, andares e dados públicos) pode ser lido por views/endpoints de somente leitura com RLS.
3. Operações que mudam estado passam por Edge Functions com JWT: iniciar hunt, resolver lote de combate, consumir poção/revive, equipar/fundir, comprar/vender, receber recompensa e demais comandos.
4. A função valida sessão, propriedade, requisitos do andar, saldo, inventário, versão de conteúdo e idempotência; calcula o resultado e persiste a transação no PostgreSQL.
5. A resposta confirmada atualiza a HUD. Retry/desconexão não pode duplicar ação, moeda, loot ou consumível.

O navegador nunca informa como verdade HP/dano final, raridade/x de drop, saldo, propriedade, resultado PvP ou autorização. Toda geração de equipamento segue o gerador/tabelas aprovados no servidor. O cliente não recebe chave `service_role`, credenciais de banco nem segredo de assinatura.

### Combate idle e trabalhos longos

Edge Functions são endpoints de execução curta, não um processo de game server sempre ligado. A simulação de uma hunt deve avançar em lotes determinísticos/idempotentes no servidor, persistindo cursor/seed/versão de conteúdo e recompensas sem depender de uma aba do navegador manter autoridade. Jobs agendados/filas, limites de execução, estratégia de catch-up/offline, custo e throughput precisam ser validados na prova técnica antes de habilitar progresso desconectado.

Supabase Realtime pode avisar clientes sobre chat, presença e eventos de grupo, mas uma mensagem Realtime nunca prova que uma transação/combate aconteceu. Boss global, arena e mercado usam comando validado no servidor e gravação transacional; broadcast vem depois da confirmação.

## 4. Supabase: componentes e limites de segurança

- **Auth:** conta e sessão; papel de admin é concedido somente por procedimento confiável (allowlist/tabela protegida ou `app_metadata` gerenciada no servidor). Não confiar em `user_metadata` editável pelo próprio jogador.
- **PostgreSQL:** estado persistente de conta/jogador, inventário, hunts, carteira, guilda, market, chat e versões de conteúdo, com schema e migrações controlados.
- **RLS:** habilitada em tabelas expostas; política padrão negar escrita pública. Jogadores só acessam o próprio estado e conteúdo publicado permitido. Escritas sensíveis ocorrem em endpoint validado.
- **Edge Functions:** API server-side para ações de jogo e operações de administrador. Validar JWT/role, schema, autorização, limite de taxa, idempotência e transação em cada comando.
- **Storage:** PNGs e dados publicados; assets aprovados podem ter leitura pública. Upload/escrita e substituição são administrativos, passam por autorização, validação de arquivo e trilha de auditoria.
- **Realtime:** somente canais apropriados, com regras de acesso; não substituir transação de banco nem validação server-side.
- **Segredos:** `service_role` e secrets existem apenas em ambiente server-side Supabase. Nunca no bundle Vercel do navegador nem em variável `NEXT_PUBLIC_*`.

## 5. Conteúdo e versionamento

O painel edita dados de conteúdo tipados (atributos, raridades, skills, encontros, odds, referências de asset), não código executável. Publicação cria um **release/versionamento imutável** de dados. A API do jogo serve apenas a versão publicada; uma hunt em andamento mantém a versão com que começou para não mudar HP/loot no meio do encontro. Rollback troca a versão ativa para um release anterior sem apagar histórico.

Regras de validação incluem, entre outras: IDs únicos; referências válidas; níveis/requisitos não negativos; todos os oito atributos presentes em equipamento; x de runtime inteiro 1–50 por atributo; chance de tabela de loot totalizando 100%; duração/data de evento válida; skills dentro do limite por estrelas; imagens em formato/tamanho permitidos; nenhum item quebrado pode ser publicado.

## 6. Observabilidade e recuperação

Eventos de servidor devem gerar logs sem expor segredos ou dados pessoais excessivos. Projetar backups, recuperação point-in-time conforme plano escolhido, auditoria para ações administrativas/transações e alertas para falhas de publicação, duplicação de recompensas, inconsistências de moeda e erros de autenticação. Retenção, custo e política de privacidade serão definidas em G2.

## 7. Pontos a validar em G2

- Limites atuais de duração, memória e chamadas de Edge Functions para simulação por lotes.
- Modelo de jobs/cron/filas e comportamento ao voltar de desconexão, sem prometer offline antes de teste.
- RLS, isolamento de ambientes, quotas, custos Supabase/Vercel, backup e plano de incidentes.
- Estratégia de versão/cache de conteúdo e assets, migração, rollback e compatibilidade com sessões ativas.
- Serviço de chat/Realtime, bosses globais, arena e concorrência no market.
- Domínios finais, identidade visual, fluxo MFA/admin e política de preview deployment.

A escolha Vercel + Supabase e a separação client/server estão aprovadas. Os detalhes de implantação e limites ainda são critérios da pré-produção técnica, não pressupostos de que a infraestrutura já existe.
