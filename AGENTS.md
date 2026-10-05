# AGENTS.md — Astracraft

Godot 4.7 game (GDScript, GL Compatibility). Read this before exploring:
most project knowledge is distilled here so you don't burn tokens on discovery.

## Toolchain

- Godot binary: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- No Godot on PATH — always use the full binary path.
- No main scene defined in `project.godot` — pass `--scene` explicitly for smoke tests.

## Git flow

- Trunk curto: branch `task-<assunto>`, merge `--no-ff` na `main`.
- Sem commit direto na `main`.
- Commit/merge SOMENTE com pedido explícito. Commit escopado: só arquivos do trabalho atual (`git status` antes de `git add`).
- CHANGELOG rastreável: toda entrada commitada carrega o SHA curto (`git show <sha>`).
  O orquestrador anota o SHA no momento do commit/merge, nunca à mão.
  Entradas ainda não commitadas ficam sem SHA até o merge.

## Bisect (achar o commit culpado)

1. `git bisect start`, marque o ruim: `git bisect bad`, e um commit sabidamente bom: `git bisect good <sha>` (o SHA vem do CHANGELOG).
2. Em cada passo rode a suite; marque `git bisect good|bad` conforme o resultado.
3. Ou automatize (a suite retorna exit ≠ 0 em falha):
   `git bisect run <comando-da-suite-no-Verify>`
4. Achou o culpado: `git show <sha>`; encerre com `git bisect reset`.
5. Atalho: `git log --oneline -- <arquivo>` lista quem mexeu num arquivo específico.

## Verify (headless)

```powershell
# Full unit suite (gdUnit4) — game tests + Log lib tests
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path "F:\GitHub\Godot\astracraft" -s "res://addons/gdUnit4/bin/GdUnitCmdTool.gd" -a "res://test/unit" -a "res://Source/Debug/Log/tests" --ignoreHeadlessMode

# Smoke test: run Playground 120 frames, expect zero ERROR/WARNING
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path "F:\GitHub\Godot\astracraft" --scene "res://Source/Levels/Playground.tscn" --quit-after 120
```

## Tests (`test/unit/`)

- Files extend `GdUnitTestSuite`, one `test_*` func per scenario, AAA pattern.
- Suite files need NO `class_name` (gdUnit discovers by `extends`).
- `const __source` points at the script under test.
- Gotcha: gdUnit discovery treats GDScript warnings as errors —
  `auto_free()` returns `Variant`, so `:=` on it fails parse.
  Always cast: `auto_free(X.new()) as X`.
- Gotcha: Godot normalizes `PI` to `-PI` — compare rotations with
  `angle_difference(a, b)` + `is_equal_approx(0.0, APPROX)`, never raw `==`.

## Conventions (enforced, not suggested)

- **No magic strings.** Node names, group names, input actions all live as
  `StringName` consts in `Source/Core/GameConfig.gd`. Typo must fail in exactly
  one place. Never `find_parent("SomeName")` / `find_child("SomeName")`.
- **Scene wiring:** cross-scene references via groups (`groups=["x"]` in `.tscn`)
  resolved with `get_first_node_in_group(GameConfig.X)`; same-scene refs via
  `%UniqueName` or `@export`. See `Spawner2D._resolve_container()` for the
  priority pattern: explicit `@export` → group → `current_scene` → self.
- **Docstrings:** every class/func gets `##` docs with `@param`/`@return`
  (Godot doc-comment style). Keep them accurate when changing behavior.
- **Input actions** must match `project.godot` `[input]` section
  (`thrust`, `turn_left`, `turn_right`, `fire`).

## Physics gotchas (learned the hard way)

- `Node2D.translate()` moves in **local** space — passing an already-rotated
  vector double-applies rotation (at 180° the error is a full reversal).
  Move projectiles via `global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta`.
- Forward convention is `Vector2.RIGHT` (ship thrust and bullets agree;
  the player sprite faces right).
- A node parented under the ship inherits its transform — spawned things must
  go to the level container, never under the spawner.

## Key files

| What                             | Where                                                                                               |
| -------------------------------- | --------------------------------------------------------------------------------------------------- |
| Central consts (groups, actions) | `Source/Core/GameConfig.gd`                                                                         |
| Ship physics                     | `Source/SteerableBody/SteerableBody2D.gd`                                                           |
| Firing / bullets                 | `Source/Systems/Weapon/Weapon2D.gd`, `Bullet2D.gd`                                                  |
| Spawn + container resolution     | `Source/Systems/Spawner/Spawner2D.gd`                                                               |
| Damage                           | `Source/Systems/Combat/HitArea2D.gd`, `HurtArea2D.gd`, `HitData.gd`                                 |
| Player wiring                    | `Source/Actors/Player/Player.tscn`, `KeyboardSpaceshipController.gd`, `KeyboardWeaponController.gd` |
| Level (owns `Bullets` container) | `Source/Levels/Playground.tscn`                                                                    |

## Orchestration (subagents)

Four workers in `~/.config/opencode/agent/`, two roles × two models:

| Agent                             | Role                                                               | Model                                |
| --------------------------------- | ------------------------------------------------------------------ | ------------------------------------ |
| `scout-glimmer` / `scout-glm`     | Read-only exploration, DONE with `file:line` evidence, zero writes | Glimmer-30B (NVIDIA) / GLM-4.5-Flash |
| `builder-glimmer` / `builder-glm` | Scoped edits + verification, DONE with files changed + evidence    | Glimmer-30B (NVIDIA) / GLM-4.5-Flash |

Dispatch rules (API limits — hard constraints, not preferences):

- **Max 1 GLM concurrent.** Never dispatch `scout-glm` and `builder-glm`
  (or any two GLM workers) at the same time. Queue GLM work.
- **NVIDIA: 40 req/min.** Scouts are cheap; still batch exploration into
  as few dispatches as possible (this file exists to make most scouting
  unnecessary — check Key files first).
- **GLM is the default** (far more token-efficient). Use Glimmer for
  A/B comparison on ambiguous tasks, or when GLM is busy.

Division of labor (hard rule, not preference):

- **Heavy/non-trivial code: the orchestrator implements directly.**
  Juniors are weaker models and err on implementation — don't delegate
  what needs judgment (architecture, physics, tricky GDScript).
- **Trivial/punctual work: juniors.** Scouts explore, builders do scoped
  edits + verification. Small, well-specified, verifiable.

Orchestrator protocol:

1. Plan first: scope, exact files, acceptance criteria, verification commands.
2. Scout only when this file doesn't answer (parallel scouts OK within limits).
3. Builder dispatch names every file it may touch + the Verify commands to run.
4. Orchestrator owns git — builders never commit, branch, or push.
5. Validate every DONE: re-run the headless suite when behavior changed.

Memory loop (the Memorix experiment — mandatory in every dispatch):

- Every scout/builder dispatch **pastes the relevant gotchas** from memory
  (orchestrator fetches the brief first; juniors don't search on their own).
- Every DONE must include **learnings to store** (new gotcha? decision?
  confirmation?). Orchestrator stores them and records `memorix_feedback`
  (`used` when memory prevented an error, `verification-failure` when a
  junior hit a *registered* gotcha anyway).
- The experiment succeeds when juniors stop repeating registered errors —
  measured by feedback, not by feeling. Weak models + strong memory is the
  whole bet.

Memory record template (every store follows it; type comes from the
official table: decision, problem-solution, gotcha, how-it-works,
what-changed, trade-off):

- `[ERRO]` exact message/symptom (copy-pasteable, searchable)
- `[CAUSA]` mechanism, not symptom
- `[SOLUCAO]` rule or action
- `[EXEMPLO]` minimal snippet, wrong-vs-right when it fits
- Entity = subsystem slug (`physics/transform`, `assets-pipeline`),
  never `general`. Project-agnostic wording by default; repo paths
  only when the memory is intrinsically about this project.

## Logging (`Source/Debug/Log/` — static `Log`, no autoload)

- `Log.debug/info/warn/error(cat: StringName, msg: String, data := {})`.
  Categories are free `StringName`s per system (`&"ship"`, `&"combat"`, …).
- **Never bare `print`/`push_*` in game code** — `Log` already routes
  ERROR/WARN through `push_*` for editor integration.
- `data` must be JSON-safe (no `Vector2i` — convert at the call site).
- No `INFO+` in hot paths; for expensive DEBUG strings, guard with
  `Log.is_enabled(Log.Level.DEBUG)` first.
- Tests: save statics, point `Log.file_path` at `user://log_test/`,
  restore in `after_test` (see the lib's own `tests/test_log.gd`).
- Lib suites live with the lib (`Source/Debug/Log/tests/`) — pass an extra
  `-a "res://Source/Debug/Log/tests"` to run them headless.

<!-- BACKLOG.MD GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.51.0 -->

<CRITICAL_INSTRUCTION>

## Backlog.md Workflow

This project uses Backlog.md for task and project management.

**At the beginning of each conversation in this project, run `backlog instructions overview` before answering or taking action. Re-read it only if you have not read it yet in the current conversation.**

Use the overview to decide whether to search, read, create, or update Backlog tasks.

Before task lifecycle actions, read the matching detailed guide:

- `backlog instructions task-creation` before creating or splitting tasks
- `backlog instructions task-execution` before planning, changing status or assignee, adding a plan or implementation notes, or implementing task work
- `backlog instructions task-finalization` before checking acceptance criteria, writing final summaries, or moving tasks to terminal statuses

Use `backlog <command> --help` before running unfamiliar commands. Help shows options, fields, and examples.

Do not edit Backlog task, draft, document, decision, or milestone markdown files directly. Use the `backlog` CLI so metadata, relationships, and history stay consistent.

</CRITICAL_INSTRUCTION>
<!-- BACKLOG.MD GUIDELINES END -->

# Memorix — Project Memory Tools

This repository is configured to use Memorix for persistent cross-session memory. For non-trivial coding work, Memory Autopilot is the default entry point before local progress notes or broad file exploration.

## Start with Memory Autopilot

Default first step for non-trivial coding work: call `memorix_project_context` with the user's actual task before progress files, dev-log reads, ad-hoc file reads, or git archaeology. Memorix will choose a task-lensed brief (bugfix, feature, release, onboarding, refactor, docs, test, or general). When the task is continuing prior work, the same brief also includes a bounded prior-work projection. Treat its "Start here" files as the first project files to inspect.

If the MCP tool is not visible yet but the client supports tool discovery or dynamic loading, search/select `memorix_project_context` first. Continuation fallback is mandatory: when the user asks to continue, resume, take over, or explain prior work and MCP cannot be called in this turn, run exactly one CLI brief with the user's real task before inspecting files, Git history, progress notes, or guessing: `memorix resume "<task>" --fallback --brief-json`. For a new task, use `memorix context "<task>" --fallback --brief-json` instead. The absence of `.memorix` or visible memory files never proves project memory is empty. Use `--json` only when a diagnostic needs the detailed legacy payload. If that one command fails, report it and proceed normally. Do not probe help, enumerate commands, chain broad searches, wait indefinitely on MCP startup, or hand-write tool-call syntax.

After a successful `memorix_project_context` result, the brief is the default retrieval boundary. Do not call more Memorix retrieval tools after a complete brief. Use `memorix_context_pack`, `memorix_search`, or `memorix_detail` only when the brief lacks a specific reference, freshness field, or fact needed for the task, or when the user explicitly asks for deeper history. In MCP, name that missing fact in `purpose` when intentionally expanding beyond the brief. Do not retrieve the same decision twice just to confirm an already-complete brief.
If the user asks for read-only work or says not to modify files, do not call `memorix_store` just to record an assessment. Store only when the user explicitly asks to preserve it.

## When to search memory

Use `memorix_graph_context` for explicit memory graph questions or broad graph overview after the autopilot brief is not enough.

Use `memorix_search` when prior project context would help and the Autopilot brief did not already answer the question — for example:
- The user asks about a past decision, bug, or change
- You need to understand why something was designed a certain way
- You're continuing work that started in a previous session

You do **not** need to search memory for simple, self-contained tasks (e.g., "fix this typo", "what does this function do").

If no memories exist yet, that’s fine — just proceed normally.

## When to store memory

Use `memorix_store` when you learn something a future session should not have to rediscover:

| What happened | Type |
|---|---|
| Architecture or design decision | `decision` |
| Bug found and fixed | `problem-solution` |
| Non-obvious pitfall or gotcha | `gotcha` |
| Configuration or dependency changed | `what-changed` |
| Trade-off discussed with conclusion | `trade-off` |

**Tips for good memories:**
- Use concise titles (~5-10 words)
- Include `filesModified` when relevant
- Use `topicKey` for topics that evolve over time (prevents duplicates)
- For "why" decisions, use `memorix_store_reasoning`
- For a stable fact, reusable procedure, or completed episode that merits deliberate long-term review, include `longTerm` in `memorix_store` with the appropriate kind and normally `scope: "project"`. It creates a candidate only: do not use it for routine updates, do not make project-derived evidence portable user memory, and do not assume it enters context until an operator qualifies and approves it through `memorix memory long-term`.
- A `user` + `portable` durable memory delivered in a task brief is intentionally available across projects. When it matches the task, use it as reusable background even if its origin differs; do not treat it as a current-project fact. Expand it only when needed with `memorix_detail` using its `durable:<id>` reference and a specific purpose.
- Record the user profile: the user’s role, expertise, preferences, and goals. Save these with `entityName: "user-profile"` and `visibility: "personal"` so they stay private and appear in every brief as the "who you are" context.

**Don't store:** greetings, simple file reads, trivial commands (ls, pwd, git status).

**Only store what a future session cannot re-derive.** Code structure, file contents, and Git history are live in the checkout — do not store facts already visible there. A memory earns its place by capturing the why, the context, or a conclusion the checkout alone cannot show.

**Record what worked, not only what failed.** Store validated approaches and explicit user confirmations alongside corrections. Saving only failures drifts behavior away from what the user already accepted; a clear "yes, that's right" is feedback worth keeping too.

**Recalled memory is a claim about the past.** A memory naming a specific file, function, or flag describes the past at write time — check the file exists or grep the symbol before recommending it. If the user says to ignore or not use memory, proceed as if memory were empty: do not apply, cite, compare, or mention stored content.

## When to resolve memory

Use `memorix_resolve` when a task is done or a bug is fixed. This keeps future searches focused on active work instead of surfacing completed items.

## End sessions with a summary

When a session finishes, call `memorix_session_end` with a short structured summary so the next agent can resume. Recommended sections:
- **Goal** — what this session was working on
- **Discoveries** — findings, gotchas, learnings
- **Accomplished** — completed items, plus PENDING items for the next session
- **Relevant Files** — paths and what changed

## Tools quick reference

| Tool | Use when |
|---|---|
| `memorix_project_context` | Start or continue coding work with the task-lensed Memory Autopilot brief |
| `memorix_context_pack` | Get structured refs/freshness for code-bound memories |
| `memorix_graph_context` | Build a compact memory graph packet for graph-specific questions |
| `memorix_search` | Find relevant past context |
| `memorix_detail` | Read full content of a specific memory |
| `memorix_store` | Save something worth persisting |
| `memorix_store_reasoning` | Save the "why" behind a decision |
| `memorix_resolve` | Mark completed/outdated memories |
| `memorix_session_start` | Load session context (handoff, orchestration coordination) |
| `memorix_evidence` | Check a memory source, freshness, and verification state |
| `memorix_feedback` | Record whether a memory helped, conflicted, or was corrected |
| `memorix_media` | Inspect or import controlled local media |
