# `doc/ai` — L2-PS feature automation pack

All agents for this flow live as **flat** `.agent.md` files under two parallel locations:

- **`.cursor/agents/`** (Cursor IDE)
- **`.github/agents/`** (VS Code / GitHub Copilot)

Both directories contain the same 8 pipeline agents (Pipeline / Planner / Architect / Arch Reviewer / Developer / UT Tester / SCT Tester / Reviewer) plus `README.md`. The two copies differ only in **platform-flavored path strings** (`/workspace/.cursor/...` vs `/workspace/.github/...`, "Cursor workspace root" vs "VS Code workspace root"); the substantive pipeline logic is identical. Whichever IDE / editor you launch from, only that platform's copy needs to be present.

A single shared **`scripts/make-bundle.sh`** sits at the pack root (`scripts/` sibling to `.cursor/agents/` and `.github/agents/`) — both copies' Stage 8 (Bundle composition) phase invoke this one script. The pipeline agent locates it at preflight by Glob-searching Cursor / VS Code workspace paths for `**/scripts/make-bundle.sh`; if not found, Stage 8 is skipped (run logs remain authoritative).

**Invoke:** `@l2ps-feature-pipeline` with a feature markdown path or inline spec. **Post-run audit (no new pipeline run):** `@l2ps-feature-pipeline RUN_ROOT check ~/Downloads/l2ps-feature-runs/<FeatureId>/<SubFeatureId>-<RunStamp>/` or shorthand `@l2ps-feature-pipeline check <same-dir>` (the directory must contain `000-*-run-meta.md`) — see `l2ps-feature-pipeline.agent.md` → *RUN_ROOT check*.

**Run logs:** The pipeline agent persists every stage reply under `${RUN_ROOT} = ~/Downloads/l2ps-feature-runs/<FeatureId>/<SubFeatureId>-<RunStamp>/` (path hardcoded; no override). RUN_ROOT lives under `~/Downloads/`, outside both `/workspace/` and this pack repo, so `git status` stays clean in both repos. See pack `README.md` → *FAQ: Stage reports persistence*.

**Deliverable bundle:** At the end of every pipeline run (success / partial / escalated), Stage 8 enriches `RUN_ROOT` in place (adds `README.md` + `MANIFEST.json` + `code-changes/`) and produces a sibling tarball `${RUN_ROOT}.tar.gz`. On terminal `=== FEATURE COMPLETE ===` (`ALL MERGE-READY` / `PARTIAL` / `NONE`), the pipeline also writes `{SEQ}-<FeatureId>-<SubFeatureId>-design-document.md` (spec + FEATURE PLAN + per-FP Architect + commit pointers) before the final summary; see `l2ps-feature-pipeline.agent.md` → *Design document (pipeline-internal)* and pack `README.md` → *Design document (terminal run only)* / *FAQ: Deliverable bundle*.

**Hands-free run:** enable auto-approval for tools in the Agent session; see pack `README.md` → *Hands-free (unattended) run*.

**gNB-side shared agents / skills:** referenced by name (e.g. the `i-faster` skill, the `L2PS-coding` / `local-smith` agents) — Cursor / VS Code auto-load them from `/workspace/.cursor/{agents,skills,rules}/` (or the `.github/` mirror per the transitional rule in `.cursor/rules/prefer-cursor-over-github-paths.mdc`). The pipeline agent and stage agents reference these by their canonical slug; no path registry is needed.
