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
| Ship physics                     | `Source/Spaceship/Spaceship2d.gd`                                                                   |
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

Orchestrator protocol:

1. Plan first: scope, exact files, acceptance criteria, verification commands.
2. Scout only when this file doesn't answer (parallel scouts OK within limits).
3. Builder dispatch names every file it may touch + the Verify commands to run.
4. Orchestrator owns git — builders never commit, branch, or push.
5. Validate every DONE: re-run the headless suite when behavior changed.

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
