# Supabase schema foundation — G2 (not production-ready)

This directory is a **partial technical proof**, not a running backend. It contains one initial SQL migration, a disabled/empty seed file, Supabase CLI configuration and a PostgreSQL smoke-test harness. No Edge Function, Game API, Admin API, Auth workflow, Storage bucket/policy or gameplay transaction is included.

## Run the local SQL harness

```sh
npm install --prefix supabase
npm test --prefix supabase
npm audit --prefix supabase
```

The tests use PGlite 0.5.8, which bundles PostgreSQL 18.3, and create simulated `auth.users`, `auth.uid()` and Supabase roles. The proposed Supabase CLI config targets PostgreSQL 15. The harness checks migration syntax and selected PostgreSQL constraints/RLS/grants, but it does **not** prove compatibility with Supabase Auth, PostgREST/Data API, Edge Functions, Storage, the configured Postgres major version, production concurrency, rate limits, backups or costs.

## Supabase local proof still required

When Supabase CLI and Docker are available, start a disposable local stack and apply migrations from zero:

```sh
supabase start
supabase db reset
```

`db reset` is destructive to the local Supabase database; do not point it at staging or production. Then add tests against real Supabase Auth/Data API roles and verify the view/grants, invite flow, release flow and transactional APIs. Do not mark G2 complete from PGlite results alone.

`seed.sql` is disabled and intentionally contains no accounts or production content. The migration is a starting foundation for review; it has not been applied to a provisioned Supabase project and is not an authorization to deploy it.

## Known gaps in this foundation

Account onboarding does not yet create the chosen character, starter gear, 300 Coins or initial consumables. The 300 unequipped-item cap, slot/template compatibility, ledger-to-balance atomicity, purchase/loot transactions, idempotent response replay/body-conflict handling, the 5-second hunt engine, shared rate limiter, release publish/rollback flow and Storage policies are not implemented. Account-deletion cascades and audit-log retention were exercised only in the PGlite harness; confirm them against real Supabase Auth before relying on them.
