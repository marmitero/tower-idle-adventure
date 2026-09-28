# Supabase schema foundation — G2 (not production-ready)

This directory is a **partial technical proof**, not a running backend. It contains one initial SQL migration, a disabled/empty seed file, Supabase CLI configuration and a PostgreSQL smoke-test harness. No Edge Function, Game API, Admin API, Auth workflow, Storage bucket/policy or gameplay transaction is included.

## Current browser-first validation path

Per the current project direction, do not install Supabase CLI, Docker, or Node.js on the user's computer to configure hosted platforms. The user reports creating `tower-idle-adventure-dev` and connecting its GitHub integration to `main`; Automatic Branching/Preview Branch is disabled because it is unavailable on the current plan. The Dashboard has not been independently checked, and the repo owner/name is ambiguous: user said `idle-tower-adventure`, while this checkout's remote is `marmitero/tower-idle-adventure`. Confirm the full repo name and `.` Working Directory before enabling migration deployment. Use synthetic data only; keep the real production database disconnected until G2/security gates.

The 9 PGlite smoke tests were previously run in the agent environment; they use PGlite 0.5.8/PostgreSQL 18.3 and simulate `auth.users`, `auth.uid()` and Supabase roles. The proposed Supabase config targets PostgreSQL 15. These tests check migration syntax and selected PostgreSQL constraints/RLS/grants, but do **not** prove Supabase Auth, PostgREST/Data API, Edge Functions, Storage, provider-specific grants/config, production concurrency, rate limits, backups, or costs. A GitHub Actions workflow could run PGlite tests in a hosted runner later, without installing dependencies on the user's device; no such workflow is configured yet.

Do not mark G2 complete from PGlite alone. Since there is no per-PR Preview Branch on the current plan, confirm migration status, RLS/grants and required Auth/Data API behavior in the shared dev project after a reviewed merge to `main`. Confirm the Supabase Dashboard's migration-deploy toggle points only to the dev project; no migration application is confirmed yet.

`seed.sql` is disabled and intentionally contains no accounts or production content. The migration is a starting foundation for review; the user-reported Supabase connection does not prove it has been applied and is not an authorization to deploy it.

## Known gaps in this foundation

Account onboarding does not yet create the chosen character, starter gear, 300 Coins or initial consumables. The 300 unequipped-item cap, slot/template compatibility, ledger-to-balance atomicity, purchase/loot transactions, idempotent response replay/body-conflict handling, the 5-second hunt engine, shared rate limiter, release publish/rollback flow and Storage policies are not implemented. Account-deletion cascades and audit-log retention were exercised only in the PGlite harness; confirm them against real Supabase Auth before relying on them.
