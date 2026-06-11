---
name: i-faster
description: Comprehensive reference for the `i_faster` CLI — the gNB repo helper that wraps build, UT, FUSE SCT, TC SCT, git, CI, and one-shot workflows. Covers help/discovery (`-h`, area helps, `-i`, `-dry`), every command group with case-level examples, build artifacts, target variants, debug helpers, and pitfalls. Apply whenever the user or an agent invokes `i_faster`, asks how to use `i_faster -h`/`-i`/`-dry`, or needs to build/run a single UT or SCT case in the gNB tree. This skill is **strategy-neutral**: test-execution policy (e.g. focused-first, expand triggers) is the calling agent's responsibility, not the skill's.
---

# `i_faster` — gNB build / test / git / CI CLI

`i_faster` is the gNB repository helper script that wraps build, unit-test, FUSE / TC SCT, git, CI, and a handful of one-shot workflows behind short subcommands. This skill is the canonical command reference for the tool — discovery, command groups, examples — and is intended for any agent or user invoking `i_faster` from a gNB checkout.

The script lives outside the repo (typically under `/logserver_*/i_faster_build_tribe_shared/build_scripts/i_faster`) and is on the system `PATH` in the standard gNB dev container. Its native environment prelude is:

```
cd /workspace/
export GNB_DIR=/workspace
export BUILD_PATH=/workspace/uplane/build
```

If you script around `i_faster`, replicate that prelude or invoke `i_faster` from `/workspace`.

## Help / discovery (always start here)

| You want… | Run |
|----------|-----|
| Top-level command list + Confluence doc URL | `i_faster -h` |
| All subcommands in an area | `i_faster build -h` · `i_faster ut -h` · `i_faster fsct -h` · `i_faster sct -h` · `i_faster git -h` · `i_faster ci -h` |
| Usage of a specific subcommand | `i_faster <cmd> -h` (e.g. `i_faster but -h`, `i_faster bfsct -h`, `i_faster rfsct -h`) |
| Print env / native-command prelude | `i_faster -i` (and many subcommands accept `i_faster <cmd> -i`) |
| Preview a command without executing | append `-dry` as the **last** argument, e.g. `i_faster bps -dry`, `i_faster but base -dry`, `i_faster cu -dry` |

Pitfall: some subcommands treat plain `-h` as an action wrapper and may start environment setup. **Prefer the area helps above** (`build -h`, `ut -h`, …) — those are pure documentation — and use `-dry` whenever you are unsure. The note "If you see this display, you need to restart the docker container, otherwise I_FASTER_WORK_PATH will use the default path:/var/fpwork/ as the directory where gnb is located" indicates a stale container env; restart the container before continuing.

Full docs: <https://confluence.ext.net.nokia.com/display/L2SW3CNTribe/How+to+user+i_faster+tool>.

## Build (`i_faster build -h`)

| Command | Builds |
|---------|--------|
| `i_faster bps` | L2-PS (host) |
| `i_faster bpso` | L2-PS for Abio / ASOE on-target |
| `i_faster bpsl` | L2-PS for Abil on-target |
| `i_faster bpsp` | L2-PS for Abip on-target |
| `i_faster bpsv` | L2-PS for VDU on-target |
| `i_faster blo` | L2-LO |
| `i_faster bhidu` | L2-HI DU |
| `i_faster bhicu` | L2-HI CU |
| `i_faster plo` | L2-LO package |
| `i_faster ppso` | L2-PS package for ABIO |

Append `-dry` to any of the above to preview only.

Key artifacts (use `ls` on the artifact to decide whether a rebuild is necessary — presence usually means the cheaper case-level command suffices):

| Artifact | Path |
|----------|------|
| L2-PS host library (FUSE SCT host prerequisite) | `uplane/build/l2_ps/build/libl2ps_scthost.so` |
| L2-PS UT build tree (proxy for `but base` having run) | `uplane/build/l2_ps/build/ut/` |
| FUSE tickler environment library | `uplane/build/tickler/cpp_testsuites/fuse/testEnvironments/l2ps/libl2ps_environment.so` |
| FUSE per-testcase library | `uplane/build/tickler/cpp_testsuites/fuse/testEnvironments/l2ps/lib<TestcaseName>.so` |

## Unit tests (`i_faster ut -h`)

Subcommands: `but` (build), `rut` (run), `gut` (gdb), `ctl` (count preprocessed LoC of a single UT file).

### `i_faster but <…>` — build

| Form | Purpose |
|------|---------|
| `i_faster but` | Build **all** UT cases (default enables debug option) |
| `i_faster but base` | **First-time bootstrap** — required once in a fresh environment before any case-level `but` |
| `i_faster but <CaseName>` | Build a single UT case, e.g. `i_faster but TestDmrsPortAllocationDl` |
| `i_faster but common` | Build common UTs under `uplane/common/` |
| `i_faster but <args> -dry` | Preview only |

### `i_faster rut <…>` — run

| Form | Purpose |
|------|---------|
| `i_faster rut` | Run **all** UT cases |
| `i_faster rut <CaseName>` | Run a single UT case |
| `i_faster rut <CaseName> <testMethodName>` | Run a single test method inside a case, e.g. `i_faster rut TestSrsBmCoMaData testReset` |
| `i_faster rut common` | Run common UTs |

### Debug / inspection

| Form | Purpose |
|------|---------|
| `i_faster gut <CaseName>` | gdb-debug a UT case |
| `i_faster ctl <ut_file>` | Count a single UT file's preprocessed LoC (also exposed top-level) |

## FUSE SCT (`i_faster fsct -h`)

Subcommands cover host (no suffix) and target variants (`o`/`l`/`p`/`v`). Host is the most common path for AI agents.

### `i_faster bfsct <…>` — build (host)

| Form | Purpose |
|------|---------|
| `i_faster bfsct` | Build **all** FUSE SCT cases |
| `i_faster bfsct tickler` | Build the tickler framework — **required once** before any case build in a fresh environment |
| `i_faster bfsct tickler --debug` | Tickler with `DEBUG_SYMBOLS` for gdb |
| `i_faster bfsct tickler <CaseName>` | Build tickler + a single case together (the recommended first build of a brand-new case) |
| `i_faster bfsct <CaseName>` | Incremental build of one case, e.g. `i_faster bfsct cb8360A_UlMuMimoBase` |

Target variants: `bfscto` (Abio), `bfsctl` (Abil), `bfsctp` (Abip), `bfsctv` (VDU); same argument shape as `bfsct`. The L2-LO counterpart is `blosct`.

### `i_faster rfsct <…>` — run (host)

| Form | Purpose |
|------|---------|
| `i_faster rfsct <CaseName>` | Run **all** run-ids of one case, e.g. `i_faster rfsct cb8360A_UlMuMimoBase` |
| `i_faster rfsct <CaseName> <RunId>` | Run a single run-id, e.g. `…cb8360A_UlMuMimoBase 1CC_2UE_TDD500_CFG_SA_OneSubcell_BlindPair` |
| `i_faster rfsct <feature_name>` | Run all cases under a feature directory, e.g. `i_faster rfsct ft1729` (also works for `CB...` Feature IDs that map to `testcases/<FeatureId>/`) |

Target variants and extras:

| Form | Purpose |
|------|---------|
| `i_faster rfscto / rfsctl / rfsctp / rfsctv` | Run on Abio / Abil / Abip / VDU target |
| `i_faster rfscto <Case> <RunId> <IP> b <build_path>` | Override build path |
| `i_faster rfscto <Case> <RunId> <IP> abio506` | Pin to an abio506/507 board |
| `i_faster rfscto <Case> <RunId> <IP> --repeat N` | Repeat the run N times |
| `i_faster rfscto <Case> <GroupRunId> <IP> g [r 1 abio506 fy …]` | Grouped multi-faster runs |
| `i_faster rfsct_vdu / dfsct_vdu / wfsct_vdu / gfsct_vdu` | Host VDU platform variants |

For target-variant grammar, prefer `i_faster rfscto -h`.

### Debug / inspection

| Form | Purpose |
|------|---------|
| `i_faster dfsct <CaseName> <RunId>` | Run with extra debug logs |
| `i_faster wfsct <CaseName> <RunId>` | Run with debug logs + TTI trace + wireshark capture |
| `i_faster gfsct <CaseName> <RunId>` | gdb-debug a case (case must be built with `bfsct tickler <CaseName> --debug`) |
| `i_faster wlosct <CaseName>` | L2-LO FUSE SCT run with wireshark |
| `i_faster sfsct <args>` | Search FUSE SCT config / log files |

### Long-running run guidance

If `rfsct` (or any of its variants) does not return within ~120 s, run it in a background terminal and poll its output for completion markers (`SRunner is exiting`, `PASSED`, `FAILED`, `error`). Kill stuck runs with `pkill -f SRunner.py` or `pkill -f <testcase>` and inspect partial logs under `logs/latest/logs/*.log`.

Common post-run inspection:

```bash
ls logs/latest/logs/*.log                       # enumerate run logs
cat logs/latest/junit-report.xml                # overall verdict
cat logs/latest/logs/*TestCaseOutput.json       # verdict + artefacts
cat logs/latest/log_file_check_report.json      # known-issue pattern matches
```

## TC SCT (`i_faster sct -h`)

Used for TC-style SCT under `uplane/L2-PS/tc/`.

| Form | Purpose |
|------|---------|
| `i_faster bsct` / `bsctl` / `bscto` | Build **all** or a specific TC SCT case (host / Abil / Abio) |
| `i_faster rsct <CaseName>` | Run a specific TC SCT case |
| `i_faster dsct <CaseName>` | Run with debug logs |
| `i_faster gsct <CaseName>` | gdb-debug |
| `i_faster wsct <CaseName>` | Run with debug + TTI + wireshark |

## Git helpers (`i_faster git -h`)

Short aliases for common git operations:

| Form | Equivalent / purpose |
|------|----------------------|
| `i_faster gb` | `git branch` |
| `i_faster gl` / `gl1` / `gls` | `git log` shortcuts (full / one-line / short) |
| `i_faster s` | `git status` |
| `i_faster d` | `git diff` |
| `i_faster a` | `git add` |
| `i_faster b` | `git blame` |
| `i_faster co` | `git commit -a -m` with a default message |
| `i_faster m` | `git commit --amend` |
| `i_faster rb` | `git rebase -i [commit_id]` |
| `i_faster ru` | `git remote update origin --prune` |
| `i_faster sbts` | sbts version check |
| `i_faster dc` | List submissions between commits |

## CI (`i_faster ci -h`)

`i_faster ci` wraps the repo CI framework command — pass the job as you would to `framework-cmd run …`. Example: `i_faster ci <job_name>`.

## One-shot / utility commands (from `i_faster -h`)

| Command | What it does |
|---------|--------------|
| `i_faster ua` | One-shot pipeline: pull + build one UT + `bps` + `bfsct` |
| `i_faster pt` | Push to master |
| `i_faster pp` | Push to master without running CI jobs |
| `i_faster cistart` | Periodic daily-task scheduler (add `-h`) |
| `i_faster pull` | Fetch the latest code |
| `i_faster sub` | Update submodule |
| `i_faster cu` | Cleanup project folder (rare workaround) |
| `i_faster cb` | Clear L2-PS build result |
| `i_faster fm` | clang-format |
| `i_faster bsf` | Compile a single file |
| `i_faster sitf` | Search `itf` hpp definition file |
| `i_faster itf` | Manually generate failed `.mt` interface |
| `i_faster crash` | Download release dbg file + run `addr2line` |
| `i_faster gsc` | Checkout 5G NR source code |
| `i_faster knife` | Helper to build a "knife" of L2-PS |
| `i_faster cdb [l2ps|l2ps_ut|fuse] [--linsee]` | Generate `compile_commands.json` for clangd (add `--linsee` if VS Code is wired to linsee directly without a container) |
| `i_faster vnc` | Start VNC service |
| `i_faster dk` / `ice` / `work` | Docker helpers (start docker / start with ice-cream cluster / open existing docker on linsee) |
| `i_faster show` | Show env-para and `scp` command |
| `i_faster shark` | Download bip log wireshark plugin (Windows) |

## Notes & pitfalls

- **`-i` semantics vary.** Some subcommands print only env prelude and `cmd not found!`; others trigger work. Use `-h` for safe discovery; reach for `-i` only when you specifically want the env prelude.
- **`-h` may trigger work on individual subcommands.** Prefer the area helps (`build -h`, `ut -h`, `fsct -h`, `sct -h`, `git -h`, `ci -h`) which are pure documentation.
- **`-dry` must be the last argument** in the command line.
- **Container restart message.** Output starting with "If you see this display, you need to restart the docker container…" means `I_FASTER_WORK_PATH` is stale — restart your dev container before continuing.
- **Always-printed native prelude.** Every invocation prints the `[native commands]` block (`cd /workspace/`, `export GNB_DIR=...`, `export BUILD_PATH=...`). Treat it as informational, not as part of the result.

## Cross-references

- Host FUSE SCT how-to (full build / run / debug walkthrough): `/workspace/.cursor/agents/l2ps-fuse-sct.agent.md`.
- UT scaffolding (mock system, file template, CMake registration): `/workspace/.cursor/skills/l2ps-ut-generate/SKILL.md`.
- Repo commit-message conventions: `/workspace/.cursor/skills/commit-message-rules/SKILL.md`.
