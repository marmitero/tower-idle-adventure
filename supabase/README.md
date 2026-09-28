# Supabase schema foundation — G2 (not production-ready)

This directory is a **partial technical proof**, not a running backend. It contains one initial SQL migration, a disabled/empty seed file, Supabase CLI configuration and a PostgreSQL smoke-test harness. No Edge Function, Game API, Admin API, Auth workflow, Storage bucket/policy or gameplay transaction is included.

## Current browser-first validation path

Per the current project direction, do not install Supabase CLI, Docker, or Node.js on the user's computer to configure the hosted platforms. Connect a dev-only Supabase project to GitHub through **Project Settings → Integrations → GitHub Integration**, with `.` as Working Directory. If the plan supports Automatic Branching, a GitHub PR creates a Supabase Preview Branch and its migrations are applied from `supabase/migrations/`. Inspect branch status and schema in the GitHub/Supabase browser dashboards; use synthetic data only. Keep the project's real production database disconnected until G2/security gates.

The 9 PGlite smoke tests were previously run in the agent environment; they use PGlite 0.5.8/PostgreSQL 18.3 and simulate `auth.users`, `auth.uid()` and Supabase roles. The proposed Supabase config targets PostgreSQL 15. These tests check migration syntax and selected PostgreSQL constraints/RLS/grants, but do **not** prove Supabase Auth, PostgREST/Data API, Edge Functions, Storage, provider-specific grants/config, production concurrency, rate limits, backups, or costs. A GitHub Actions workflow could run PGlite tests in a hosted runner later, without installing dependencies on the user's device; no such workflow is configured yet.

Do not mark G2 complete from PGlite alone. The hosted Preview Branch must also be checked for migration status, RLS/grants and the Auth/Data API behaviors required by the app.

`seed.sql` is disabled and intentionally contains no accounts or production content. The migration is a starting foundation for review; it has not been applied to a provisioned Supabase project and is not an authorization to deploy it.

## Known gaps in this foundation

Account onboarding does not yet create the chosen character, starter gear, 300 Coins or initial consumables. The 300 unequipped-item cap, slot/template compatibility, ledger-to-balance atomicity, purchase/loot transactions, idempotent response replay/body-conflict handling, the 5-second hunt engine, shared rate limiter, release publish/rollback flow and Storage policies are not implemented. Account-deletion cascades and audit-log retention were exercised only in the PGlite harness; confirm them against real Supabase Auth before relying on them.
