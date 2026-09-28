# G2 — blueprint técnico do MVP

**Versão:** 0.1 — especificação de pré-produção
**Status:** baseline técnico proposto/selecionado pelo agente para orientar validação G2; nenhuma migração, função, aplicação ou serviço foi implementado ou provisionado. Não equivale ao gate G2 aprovado.

Este documento detalha a direção Vercel + Supabase de [`TECH_ARCHITECTURE.md`](TECH_ARCHITECTURE.md) para o MVP de [`MVP_DECISIONS.md`](MVP_DECISIONS.md). Regras de produto do MVP não são reabertas aqui. Decisões técnicas dependentes de plano, custo e uma prova técnica ainda precisam de verificação antes de G2 ser encerrada.

## 1. Decisões de arquitetura para validar

1. **Linguagem compartilhada:** TypeScript para Game Web, Admin Web e Edge Functions; contratos JSON e tipos gerados a partir do schema.
2. **Game Web:** Next.js/React em um projeto Vercel próprio. PixiJS fica isolado no palco de batalha para renderização 2D; menus, HUD, inventário e formulários permanecem HTML acessível. PixiJS é uma escolha inicial para prova de renderização, não implementação de combate.
3. **Admin Web:** Next.js/React em outro projeto Vercel e outro domínio. Não compartilhar páginas, bundle, sessão de cliente ou variáveis privilegiadas com o Game Web.
4. **Backend:** Supabase Auth + PostgreSQL + Edge Functions + Storage. Edge Functions autenticam, validam e orquestram; operações de estado usam funções SQL transacionais/restritas. Não haverá processo de simulação em background no MVP.
5. **Autoridade:** todas as mutações de perfil, equipe, itens, Coins, consumíveis, sessão de hunt e conteúdo passam por endpoints server-side. O cliente envia intenção e `request_id`, nunca resultado ou tempo de simulação.
6. **Sem progresso offline:** um lote só avança por comando ativo aceito; não há cron/catch-up. Após reconectar, a sessão retoma do último cursor persistido, sem simular o intervalo desconectado.

**Prova técnica G2 necessária:** validar chamada TypeScript → Edge Function → transação PostgreSQL, limites/custo de lotes, autenticação/MFA e isolamento real do Admin Web antes de congelar versões/bibliotecas.

## 2. Projetos e ambientes

| Camada | Desenvolvimento local | Staging | Produção |
|---|---|---|---|
| Game Web | Next.js local + Supabase CLI local; dados sintéticos | projeto Vercel + projeto Supabase isolados | projeto Vercel + projeto Supabase exclusivos |
| Admin Web | execução local com usuário/roles seed não produtivos | deployment protegido; sem conteúdo/segredo de produção | projeto Vercel/domínio separados; middleware exige sessão admin válida |
| Conteúdo | fixtures versionadas e sem dados pessoais | cópia sintética do release aprovado | release imutável publicado pelo Admin autorizado |

- Usar os diretórios/projetos `game-web`, `admin-web` e `supabase/` como convenção futura; não criar estas aplicações durante a etapa documental.
- `supabase/migrations/` contém SQL versionado; `seed.sql` contém somente fixtures sintéticas. Mudanças de schema passam por review, aplicam-se primeiro no local e staging e só então production.
- Vercel Preview nunca recebe segredo de produção. Por padrão, preview do Game Web usa ambiente dev/sintético; Preview do Admin Web deve ter Vercel Deployment Protection e não consegue publicar no banco de produção.
- Produção usa variáveis separadas por projeto/environment. Segredos do Supabase ficam apenas em funções/servidor; nenhuma chave secreta ou `service_role`/`sb_secret` pode aparecer em bundle `NEXT_PUBLIC_*`, source map ou log.
- Habilitar verificação de migration status e backup antes de qualquer release de schema; não executar reset destrutivo contra staging/production.

## 3. Domínios de dados MVP

Nomes abaixo são conceituais até revisão de schema; `auth.users.id` é a identidade canônica. Toda tabela mutável recebe timestamps de servidor e `revision` quando há concorrência.

| Entidade | Conteúdo e invariantes principais |
|---|---|
| `player_profiles` | `user_id` PK/FK de Auth, nível 1–20, XP não negativo, Coins não negativos/revision, `created_at`; sem e-mail público ou perfil social. |
| `player_roster` | Personagens desbloqueados (ID de classe, `unlocked_at`, posição opcional 1–3); `UNIQUE(user_id, class_id)` e no máximo três posições únicas. Nível é compartilhado, não duplicado por personagem. |
| `player_items` | Instância não negociável: dono, template/release, nível, raridade, oito colunas `x_* SMALLINT CHECK (x_* BETWEEN 1 AND 50)`, característica elegível, origem e timestamps. Máximo 300 instâncias não equipadas por conta; descarte é tombstone, sem transferência. |
| `equipment_loadouts` | `user_id`, personagem, slot, `item_id`; PK por `(user_id, character_id, slot)` e `UNIQUE(item_id)`. Função transacional valida que slot e dono do item correspondem ao template/perfil. |
| `consumable_stacks` | Uma linha por conta/tipo: poção ou revive, quantidade entre 0 e 99; compra/consumo atualiza estoque e ledger na mesma transação. |
| `coin_ledger` | Lançamentos append-only com valor assinado, motivo, referência/idempotency key e saldo resultante; não aceitar saldo calculado pelo cliente. |
| `bot_settings` | Limiar, lista de raridades, toggles de poção/revive/skills e retorno pós-derrota; schema fechado e limites conferidos server-side. |
| `hunt_sessions` | Uma sessão ativa por conta (índice único parcial), andar, status, `content_release_id`, `engine_version`, cursor/revision e snapshot serializado com versão. Seed/estado sensível não é exposto ao cliente. |
| `hunt_events` | Eventos de combate/recompensa ordenados por sequência; API devolve apenas os últimos 100 da hunt mais recente. Não é log de analytics livre. |
| `idempotency_records` | `(user_id, request_id)` único, rota, hash do corpo, status e resposta mínima. Mesmo ID/corpo retorna resultado original; mesmo ID com corpo diferente é conflito. TTL operacional proposto: 30 dias, sujeito a revisão de retenção. |
| `content_drafts` | Entradas tipadas editáveis (JSON validado por `kind`), autor e revisão; invisíveis a jogadores. |
| `content_releases` / `release_entries` | Release imutável, publicação atômica, checksum, autor/motivo e entradas congeladas. Hunt fixa release ao iniciar; rollback muda apenas o ponteiro ativo. |
| `admin_memberships` | `user_id`, role, estado, concedido/revogado por; tabela não editável por jogador nem exposta em leitura pública. |
| `admin_audit_log` | Ação, ator, entidade, diff antes/depois, release, motivo, data e resultado; append-only para administradores. Nunca registrar token, senha ou segredo. |

### Restrições e índices

- FKs com `ON DELETE` deliberado; preferir arquivar/tombstone para conteúdo e itens descartados a apagar histórico referenciado.
- `CHECK` para nível, XP, saldo, raridade, quantidade, faixas de bot e oito rolagens. Trait extra é não nulo somente para Lendário/Celestial (exatamente um ID elegível); template/personagem usam IDs estáveis, não rótulos traduzidos.
- Índices por `(user_id, created_at)`, sessão ativa por conta, sequência de eventos, `release_id`, estado de publicação e `request_id`.
- Invariante econômico: débito, ledger, estoque e resultado de compra/loot são uma transação. Invariante de equipe: cada membro ocupa no máximo um slot e cada item está equipado no máximo uma vez.
- JSON fica restrito a snapshots versionados, payloads de evento e drafts; campos usados em integridade/consulta permanecem colunas tipadas.

## 4. RLS, privilégios e chamadas server-side

### Matriz de acesso inicial

| Dados | Anônimo | Jogador autenticado | Edge Function/Game API | Admin API |
|---|---|---|---|---|
| Conteúdo publicado ativo | leitura apenas do catálogo público | leitura apenas do catálogo publicado | leitura | leitura |
| Perfil, elenco, inventário, hunt | nenhum | leitura das próprias linhas somente se necessária à HUD; sem INSERT/UPDATE/DELETE direto | leitura e mutação autorizadas | nenhuma mutação por conveniência |
| Drafts/releases não ativos | nenhum | nenhum | nenhum, salvo API pública específica | acesso por role e workflow |
| Roles/auditoria administrativa | nenhum | nenhum | nenhum | Owner/Editor/Auditor conforme matriz; mutação via função protegida |
| Ledger/estado de compra | nenhum | leitura limitada do próprio histórico/saldo | escrita transacional autorizada | leitura auditada; ajuste excepcional fora do painel de conteúdo |

### Regras obrigatórias

1. Habilitar RLS nas tabelas expostas e configurar **grants e policies em conjunto**. Revogar privilégios default de `anon`/`authenticated` e conceder somente leitura pública de catálogo publicado e leitura própria indispensável.
2. Bloquear escrita direta por `anon`/`authenticated` em perfil, inventário, ledger, consumíveis, equipe, sessão e conteúdo. UI jamais recebe `service_role`/`sb_secret`.
3. Edge Function valida assinatura/expiração do JWT e extrai `user_id` do token. Ignorar qualquer `user_id` de body/query para autorização.
4. Funções SQL transacionais ficam em schema de aplicação controlado, com `EXECUTE` revogado de `PUBLIC`, `anon` e `authenticated`; somente identidade server-side autorizada pode chamá-las. Funções `SECURITY DEFINER` fixam `search_path`, validam argumentos e não montam SQL dinâmico.
5. Para endpoints de jogador, derivar dono do JWT verificado e passar esse ID à transação. Para Admin API, consultar `admin_memberships` em cada request; não confiar em `user_metadata`, role cacheável do browser nem rota escondida.
6. Views públicas de conteúdo incluem somente release ativo e campos aprovados; draft, auditoria, seed e configuração interna não são legíveis no Game Web.
7. Game API e Admin API usam allowlist CORS por origem exata (prod + local dev apenas; Preview é explicitamente configurado), `Vary: Origin` e métodos/headers mínimos. CORS não é autorização: JWT/role e validação server-side valem para curl e qualquer cliente.
8. Testar cada tabela/função com usuário A, usuário B, `anon`, editor, auditor e owner. RLS não substitui validação de domínio nem idempotência.

### Baseline inicial de rate limit (a provar/ajustar em G2)

Limites são contabilizados por conta **e** IP, por rota, respondem `429` com `retry_after` e não substituem autenticação/idempotência. IP vem apenas do header canônico fornecido pelo proxy confiável, nunca de um header encaminhado livremente pelo browser. Valores são baseline do agente para teste de carga/custo, não escolhas individuais do usuário nem controles ativos:

- Leituras autenticadas: 120/min por conta e 300/min por IP; leitura pública de catálogo: 60/min por IP.
- Mutação de jogo: 30/min por conta e 120/min por IP; compra: no máximo 10/min por conta.
- `hunts/advance`: no máximo 1 lote novo a cada 5 s por sessão (12/min); retries idempotentes do mesmo `request_id` não consomem outro lote.
- Convite/reenviar link de Auth: até 5/h por e-mail e por IP; convite de Admin: 5/h por Owner; publicação/rollback: 20/h por Admin. Aplicar também proteção contra brute force e quotas nativas disponíveis.
- Ajustar após medir tráfego legítimo, latência e preço; limites nunca podem ser afrouxados para contornar economia ou segredo exposto. Não usar memória local de uma Edge Function como contador distribuído.
- Candidato inicial: bucket atômico compartilhado no PostgreSQL com chaves de IP pseudonimizadas (HMAC) e TTL máximo de 24 h, sem IP bruto em logs; provar latência/custo. Se não escalar, justificar e aprovar um rate limiter externo antes de adicioná-lo à stack.

## 5. Contratos de API do jogo

Todas as mutações usam HTTPS, JWT Supabase, JSON schema versionado e `request_id` UUID. Envelope recomendado:

```json
{
  "request_id": "uuid",
  "expected_revision": 12,
  "payload": {}
}
```

Resposta de comando confirmada inclui `request_id`, `state_revision`, `server_time`, snapshot mínimo atualizado e eventos novos. Erro inclui `code`, mensagem segura e `retryable`; nunca retorna stack trace ou SQL.

| Comando | Intenção do cliente | Validação/efeito server-side |
|---|---|---|
| `GET /game/bootstrap` | abrir app | autenticar; devolver perfil, roster, saldos, estado atual e `content_release_id` publicado. |
| `GET /game/catalog` | carregar conteúdo | ler apenas release publicado e imagens autorizadas, com `ETag`/cache versionado. |
| `POST /game/team` | ordem/membros desejados | roster desbloqueado, até 3 IDs distintos, posições 1–3; concorrência por revision. |
| `POST /game/items/equip` | `item_id`, personagem e slot | dono, nível mínimo, slot/subtipo, unicidade e afinidade; atualiza loadout em transação. |
| `POST /game/items/discard` | item a descartar | item do próprio perfil e não equipado; soft-delete e audit event. |
| `POST /game/bot-settings` | configuração desejada | ranges, raridades/itens elegíveis e estado; salva versão validada. |
| `POST /game/shop/purchase` | tipo e quantidade | preço do catálogo server-side, estoque ≤99, Coins, idempotência; debita e credita atomicamente. |
| `POST /game/hunts/start` | andar escolhido | nível mínimo, sessão inexistente, equipe/configuração, release ativo; cria seed e cursor no servidor. |
| `POST /game/hunts/advance` | só `session_id`, `request_id`, `expected_revision` | aplica lote fixo elegível no servidor; não aceita `elapsed_ms`, dano, alvo, resultado ou loot do cliente. |
| `POST /game/hunts/end` | encerrar sessão | encerra no cursor persistido; concede apenas recompensas já confirmadas e mantém log definido. |
| `GET /game/hunts/current` | recuperar snapshot/log | apenas estado próprio; não avança combate nem concede progresso. |

### Códigos de erro estáveis

`AUTH_REQUIRED`, `EMAIL_NOT_VERIFIED`, `INVITE_REQUIRED`, `FLOOR_LOCKED`, `HUNT_ALREADY_ACTIVE`, `HUNT_NOT_ACTIVE`, `REVISION_CONFLICT`, `IDEMPOTENCY_CONFLICT`, `ITEM_NOT_OWNED`, `ITEM_LEVEL_TOO_HIGH`, `INVENTORY_FULL`, `INSUFFICIENT_COINS`, `STACK_LIMIT`, `RATE_LIMITED`, `CONTENT_RELEASE_UNAVAILABLE` e `VALIDATION_ERROR`.

Semântica de retry: `REVISION_CONFLICT` exige refresh e decisão da UI; `RATE_LIMITED` traz `retry_after`; erro de rede repete o mesmo `request_id`; não criar novo ID até resolver o resultado da tentativa anterior.

## 6. Sessão e lote de combate sem progresso offline

- Ao iniciar hunt, servidor persiste `status=active`, andar, versão de conteúdo/engine, cursor, estado inicial e seed não exposto. Uma conta não pode ter duas hunts ativas.
- Enquanto a página autenticada está conectada, o cliente solicita um lote de **5 segundos de simulação** a cada 5 segundos reais. É quantum fixo definido pelo servidor; o body não envia tempo transcorrido.
- Um lote tenta aplicar ações até `sim_time + 5 s`, com limite defensivo de 256 eventos ordenados por request. Se atingir o limite antes do horizonte, persistir somente o prefixo ordenado já resolvido, marcar `batch_incomplete`, emitir alerta e continuar do cursor exato/horizonte pendente no próximo request online antes de iniciar outro quantum; nunca pular evento nem conceder recompensa duas vezes.
- Server rate limit aceita no máximo um novo lote por sessão a cada 5 s. Chamadas antecipadas não avançam relógio. Um retry com o mesmo `request_id` retorna exatamente a resposta já persistida, sem novo lote.
- Não existe worker/cron para hunt. Sem request conectado, o cursor não avança. Uma chamada posterior processa apenas o lote atual, nunca o intervalo perdido; `GET current` é somente leitura. Ao reconectar, a UI carrega o último snapshot e retoma enviando novo comando ativo.
- Transação grava cursor, HP/status, ledger, consumíveis, loot, evento e revision de forma atômica. Falha/timeout não pode duplicar reward. Estado usa seed derivada no servidor e versão de engine para replays de suporte.
- A sessão fixa release de conteúdo ao começar; publicar novo conteúdo não muda uma hunt existente. Últimos 100 eventos confirmados são mantidos para UI; não são analytics de longo prazo.

Este modelo é uma decisão de arquitetura para validar na prova técnica G2. Se os limites de Edge Functions/PostgreSQL impedirem o lote, não se reabre progresso offline: revisa-se o mecanismo server-side e registra-se a alternativa antes de implementar.

## 7. Admin: workflow e autorização

Roles finais recomendadas para MVP:

| Ação | Owner | Editor | Auditor |
|---|---:|---:|---:|
| Ler conteúdo publicado, drafts e histórico | sim | sim | sim |
| Criar/editar/validar drafts | sim | sim | não |
| Publicar release/rollback | sim | não (submete para Owner) | não |
| Convidar/revogar admins | sim | não | não |
| Ver relatório de auditoria | sim | limitado ao próprio trabalho | sim, leitura |

- Primeiro Owner é provisionado fora do cliente por um procedimento operacional documentado; não existe rota de autoelevação/auto-cadastro admin.
- Supabase Auth envia convite de player somente por fluxo confiável server-side; signup público fica desabilitado, email precisa ser confirmado. Link de convite expira em 24 h e é de uso único; administradores também são provisionados por Owner.
- MFA TOTP obrigatório para qualquer conta admin em produção. Baseline: sessão Admin expira após 30 min de inatividade ou 8 h absolutas; publish, rollback, role change e ação destrutiva exigem MFA/reautenticação nos 10 min anteriores. Provar suporte/configuração e UX do provedor antes de G2; não são controles já ativos.
- App Admin verifica autenticação e role antes de renderizar shell/dados; páginas privadas são dinâmicas, sem prerender/cache público. Cada endpoint revalida role e schema.
- Vercel Deployment Protection protege todos os previews. Produção combina gate do app/server-side com Vercel access control conforme plano disponível; nenhuma camada isolada é tomada como autorização de dados.
- Draft → validate → preview → aprovação Owner → release imutável → ponteiro ativo. Rollback aponta para release anterior e gera nova entrada auditável; não sobrescreve release.

## 8. Storage, privacidade e operações

- Buckets separados: `content-drafts` privado para Owner/Editor; `content-published` somente leitura de assets referenciados por release. Caminhos incluem `release_id/asset_id/hash`; substituição cria novo objeto.
- MVP aceita PNG raster estático; baseline por arquivo: até 5 MiB e 4096×4096 px (máx. 16 MP), validar MIME real/decode/checksum e normalizar/retirar metadados antes de publicar. Rejeitar SVG, HTML, script, fonte executável e arquivo compactado. Confirmar limites do Storage/CDN e latência no teste G2.
- Perfil do jogo guarda só `user_id`, estado e eventual nome de exibição escolhido; e-mail permanece em Supabase Auth, não público. Não coletar data de nascimento, localização precisa ou chat (fora do MVP).
- Log da hunt: últimos 100 eventos até a próxima hunt. Retenção de logs operacionais proposta: 30 dias; trilha administrativa proposta: 12 meses. Confirmar com revisão LGPD/contrato do provedor antes do beta, sem reter payload desnecessário.
- Planejar exclusão de conta pelo suporte, com remoção/cascata de dados de gameplay e política documentada para registros operacionais/anônimos. Sem pagamento/market no MVP, portanto sem ledger comercial de longo prazo.
- Backup: alvo mínimo de snapshot diário e retenção de 7 dias, mais exercício de restauração em staging antes do beta. Validar plano/preço Supabase, export e PITR disponíveis; não declarar backup ativo antes de testar restore.
- Observabilidade: métricas agregadas de erro/latência/duplicação/uso, sem conteúdo de request com e-mail/token. Alertar falhas de release, taxa anormal de compra/recompensa, revision conflicts e abuso de API.

## 9. Critérios de saída G2 (ainda não executados)

- Prova local que inicia Supabase CLI, aplica migrations do zero, carrega seeds sintéticas e restaura banco sem ação manual fora do roteiro.
- Testes automatizados de RLS/grants para anon, jogador A/B e roles Admin; tentativa direta de escrita falha.
- Rate limits cumprem os valores aprovados ou revisados no ambiente-alvo, compartilham contadores entre instâncias, retornam `429/retry_after` e não podem ser evitados por `X-Forwarded-For` forjado; custo/latência ficam medidos.
- Requisição duplicada de compra/lote com mesmo `request_id` não duplica Coins, item, XP, uso de poção ou cursor; body diferente sob mesmo ID retorna conflito.
- Reconexão não gera lote de catch-up; função não confia em tempo/client state.
- Release inválido não publica; publish/rollback registra actor/diff e sessões mantêm release fixado.
- Player comum recebe negação sem Admin shell/dados/API, inclusive em preview/domínio conhecido; Owner MFA consegue workflow previsto.
- Protótipo UX foi revisado com usuários de teste conforme plano de `G2_UX_BLUEPRINT.md`; achados de severidade alta tratados.
- Revisão de segurança, custos e backup aprovada antes do Gate G2. Nenhum destes critérios foi executado por esta atualização documental.

## Referências técnicas oficiais

- [Supabase — Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase — Securing your API (grants + RLS)](https://supabase.com/docs/guides/api/securing-your-api)
- [Supabase — Local development workflow](https://supabase.com/docs/guides/local-development/cli-workflows)
- [Supabase — Inviting users](https://supabase.com/docs/guides/auth/users)
- [Supabase — Edge Function secrets](https://supabase.com/docs/guides/functions/secrets)
- [Vercel — Deployment Protection](https://vercel.com/docs/deployment-protection)
