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
- Migração HP para `GameResource` + trauma derivado + logs nos sistemas
  (`160b5c3`)
- **Depleted fantasma no boot**: `ScoreSingleton` (autoload com
  `current_amount = 0`) atravessava o path de morte na desserialização;
  `set_current_amount` agora só emite `depleted`/`replenished` dentro
  da tree — runtime 1:1, sem `Depleted` no boot. (`5a32f6e`)
- Typo `defese` vira `defense` em `HurtArea2D` (declaração + 2 usos).
  (`6c0f288`)

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
- Sistema de dados asteroid: arquivos `.tres` centralizam estatísticas,
  removendo hardcode de valores (`de3728f`, `90c2a6d`)
- Sistema de combate: componentes `HurtShape` tipados, integração com
  sistema de dano (`94d4220`, `8bcda03`)
- Migração HP para `GameResource` com sistema de trauma derivado
  e integração com logging (`d63f963`)
- Sistema `GameResource` + `ScoreSingleton` com fiação completa na cena
  (`ac5beed`)

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
- Consumidor `Asteroid.gd` aplica `AsteroidStats` (visual, shapes,
  destructible); cena vira estrutura pura; `test_asteroid.gd` (5 casos).
  (`2a1ee20`)
- Sistema de dados asteroid: `AsteroidTypeA/B/C.tres` com estatísticas
  (HP, damage, visual, shapes); kinematic segue só como draft DRAFT-1
  (`60e946b`, `5ce694b`, `5975b48`)
- Gameplay de asteroides: sistema HP, estados `died`/`exploded`,
  componentes de combate integrados (`94d4220`)
- `HurtShape` tipado com sistema de tipos, cena estruturada pura,
  testes gdUnit4 integrados (`8bcda03`)
- Troca de bala `DevBullet2D` por `BulletDev` (componentes,
  sem duplicação) (`2c0fce8`)
- Reconciliação de backlog: fechamento de itens 1.1, 1.2, 1.3, 2.1
  com evidências de implementação (`4245df2`)
- Sistema `GameResource` para HP com trauma derivado e `ScoreSingleton`
  sem limite; fiação completa na cena (`ac5beed`, `d63f963`)
- Debug nametags: labels por entidade com API de toggle no autoload
  e sistema de camadas UI centralizadas (`77b6832`, `b098361`)
- Asteroide nasce com HP cheio e replenish após definir máximo (`e74f078`)
- Score sem teto + regras de orquestração documentadas no AGENTS.md
  (`cef3bf9`)
- Testes para arquitetura por exports + atlas de asteroides atualizado
  (`1b68b39`)
- Cenas por herança + componentes que se pintam, sem camada .tres
  (`53a65a8`)
- Editor: main scene, atlas reexportado, prefabs reorganizados
  (`469f9bb`)
- Reorganização de prefabs e montagem de hurtbox/asteroide no editor
  (`6ad8d26`)
- Console de debug runtime (F1 físico, zero InputMap): shell em
  `Source/Debug/Console/` + 8 comandos v1 (`help/hp/damage/heal/pos/
  score/spawn/tags`), alvos via `GameConfig.PLAYER_SHIP` + `ASTEROIDS`,
  instância por level no `Playground.tscn`; `test_debug_console.gd`
  (8 casos). (`eab3c39`)
