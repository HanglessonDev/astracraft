# Changelog — Astracraft

Formato: novas entradas no topo, em `## [Unreleased]` até a release.

## [Unreleased]

### Corrigido
- **Bala na direção errada**: `Bullet2D` usava `translate()` (espaço local)
  com vetor já rotacionado — rotação aplicada 2×, a 180° a bala saía para
  trás. Agora move via `global_position`.
- **Bala presa à nave**: `Spawner2D` procurava ancestral `"Level"`
  (inexistente — a fase é `Playeground`) e o fallback parentiava a bala
  no próprio spawner, filho da nave. Resolução agora é híbrida:
  `@export container` → grupo `GameConfig.BULLET_CONTAINER` →
  cena atual → próprio nó; copia posição e rotação globais no spawn.

### Refatorado
- **Fim das magic strings**: grupos (`BULLET_CONTAINER`, times) e input
  actions (`thrust`, `turn_left`, `turn_right`, `fire`) centralizados como
  `StringName` em `GameConfig`; `Spawner2D` sem `find_parent`/`find_child`
  por nome; `Bullets` resolvido por grupo; `common_ancestor_name` e
  `container_name` removidos (sem código morto).

### Adicionado
- Lib de logging em `Source/Debug/Log/` (`Log` estático, sem autoload).
- Testes gdUnit4: `test/unit/test_bullet2d.gd` (6 casos),
  `test/unit/test_spawner2d.gd` (5 casos).
- `AGENTS.md` (toolchain, verify, convenções, orquestração) e este changelog.
