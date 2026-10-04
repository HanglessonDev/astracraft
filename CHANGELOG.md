# Changelog — Astracraft

Formato: novas entradas no topo, em `## [Unreleased]` até a release.
Toda entrada commitada carrega o SHA curto do commit (`git show <sha>`)
— anotado pelo orquestrador no momento do commit/merge, nunca à mão.

## [Unreleased]

### Corrigido
- **Bala na direção errada**: `Bullet2D` usava `translate()` (espaço local)
  com vetor já rotacionado — rotação aplicada 2×, a 180° a bala saía para
  trás. Agora move via `global_position`. (`24deaa0`)
- **Bala presa à nave**: `Spawner2D` procurava ancestral `"Level"`
  (inexistente — a fase é `Playground`) e o fallback parentiava a bala
  no próprio spawner, filho da nave. Resolução agora é híbrida:
  `@export container` → grupo `GameConfig.BULLET_CONTAINER` →
  cena atual → próprio nó; copia posição e rotação globais no spawn.
  (`24deaa0`)
- **Spam de log por frame**: `stop_spin()` era chamado todo physics frame,
  gerando uma linha `Turn stopped` por frame. Guard por
  `angular_direction != 0.0` — dispara uma vez por solta de tecla.
  (`b39efa5`)

### Refatorado
- **Mecanismo `SpaceShip2D` vira `SteerableBody2D`**: a física (thrust+giro)
  ganha nome genérico em 1 grafia (classe+arquivo+pasta+cena); o papel
  nave continua no veículo (`Player` possui spaceship, troca de naves
  preservada); nós das cenas e `NodePath`s intactos. (`7e7b4bb`,
  `3292843`)
- **Fim das magic strings**: grupos (`BULLET_CONTAINER`, times) e input
  actions (`thrust`, `turn_left`, `turn_right`, `fire`) centralizados como
  `StringName` em `GameConfig`; `Spawner2D` sem `find_parent`/`find_child`
  por nome; `Bullets` resolvido por grupo; `common_ancestor_name` e
  `container_name` removidos (sem código morto). (`24deaa0`)

### Adicionado
- Lib de logging em `Source/Debug/Log/` (`Log` estático, sem autoload).
  (`24deaa0`)
- Instrumentação com `Log` categorizado (`ship`/`combat`/`weapon`/
  `spawner`/`input`/`config`): transições em INFO, eventos por disparo
  em DEBUG, WARN no fallback sem container. (`b39efa5`)
- Testes gdUnit4: `test/unit/test_bullet2d.gd` (6 casos),
  `test/unit/test_spawner2d.gd` (5 casos) (`24deaa0`),
  `test/unit/test_weapon2d.gd` (3 casos: suporte a multiplas armas)
  (`9951f47`).
- `AGENTS.md` (toolchain, verify, convenções, orquestração) e este
  changelog. (`24deaa0`)
