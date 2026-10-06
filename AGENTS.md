# AGENTS.md — Astracraft

Godot 4.7 game (GDScript, GL Compatibility). Read this before exploring:
most project knowledge is distilled here so you don't burn tokens on discovery.

Git flow, orquestração de subagentes e workflow Backlog: ver AGENTS.md global.
Aqui só o que é Godot/astracraft.

## Toolchain

- Godot binary: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- No Godot on PATH — always use the full binary path.
- No main scene defined in `project.godot` — pass `--scene` explicitly for smoke tests.

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

