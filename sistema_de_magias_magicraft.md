# Sistema de Magias Modular (estilo Magicraft / Noita) — Godot 4.7

> **Aviso de fidelidade:** a arquitetura abaixo é o modelo do gênero (Noita) e o que lembro do Magicraft. Nomes de magias, valores e regras finas do Magicraft **não** estão garantidos. Veja a seção 15 para o que conferir na wiki. Nada aqui depende de recurso exclusivo da 4.7: só `Resource`, `@export`, tipos tipados (`Dictionary[K, V]` existe desde a 4.4), `PackedScene` e `SceneTreeTimer`.

---

## 1. Objetivo e escopo

Um sistema onde o jogador monta uma **varinha** com **slots**, cada slot contendo uma **magia**. A ordem dos slots define o resultado: modificadores alteram a magia seguinte, multicast dispara várias, triggers anexam uma magia-carga a um evento.

**Fora do escopo do MVP:** loot, economia, UI polida, relíquias, status complexos.

**Princípio central:** *a lista de slots é código-fonte; o jogo compila essa lista em uma árvore de cast e executa a árvore.* Nunca execute os slots diretamente.

---

## 2. Glossário

| Termo | Definição |
|---|---|
| **Slot** | Posição na varinha que guarda 0 ou 1 `SpellData` |
| **Unidade** | Menor trecho de slots que forma um disparo válido (ex.: `[Dano+, Bola de fogo]`) |
| **Passo de cast (step)** | Uma unidade top-level disparada por um clique. Depois dele vem o *cast delay* |
| **Ciclo** | Percorrer a varinha inteira. Ao fim vem o *recharge delay* |
| **Portador (carrier)** | Projétil que carrega um trigger/timer |
| **Carga (payload)** | Unidade que é disparada quando o evento do portador ocorre |
| **CastNode** | Nó da árvore compilada |
| **Pending mods** | Modificadores já lidos, esperando a próxima unidade para serem aplicados |

---

## 3. Tipos de magia e responsabilidades

| Kind | Faz o quê | Consome do que vem depois |
|---|---|---|
| `PROJECTILE` | Gera uma entidade que causa efeito | nada |
| `MODIFIER` | Soma/multiplica stats ou liga flags (pierce, bounce, homing) | 1 unidade (modifica toda ela) |
| `MULTICAST` | Dispara N unidades no mesmo passo | N unidades |
| `TRIGGER` | Anexa uma carga ao evento "ao acertar" do portador | 1 unidade (portador) + 1 unidade (carga) |
| `TIMER` | Igual ao trigger, mas o evento é "após T segundos" | idem |

Extensões futuras (não MVP): `FORMATION` (círculo, linha), `ON_EXPIRE`, `ON_KILL`, modificadores "todas as seguintes" (`consumes_next > 1`).

---

## 4. Modelo de dados

### 4.1 `SpellData` (Resource)

```gdscript
class_name SpellData extends Resource

enum Kind { PROJECTILE, MODIFIER, MULTICAST, TRIGGER, TIMER }

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var kind: Kind = Kind.PROJECTILE
@export var mana_cost: float = 0.0

@export_group("Projétil")
@export var projectile_scene: PackedScene
@export var base_damage: float = 10.0
@export var base_speed: float = 400.0
@export var base_lifetime: float = 2.0

@export_group("Modificador")
## Somados antes dos multiplicadores. Ex.: {&"damage": 5.0, &"pierce": 1.0}
@export var add_mods: Dictionary[StringName, float] = {}
## Multiplicadores. Ex.: {&"damage": 1.5, &"speed": 0.8}
@export var mult_mods: Dictionary[StringName, float] = {}
## Flags de comportamento. Ex.: [&"homing", &"bounce"]
@export var flags: Array[StringName] = []

@export_group("Multicast")
@export var multicast_count: int = 2
@export var spread_degrees: float = 15.0

@export_group("Timer")
@export var timer_seconds: float = 0.5
```

### 4.2 `WandData` (Resource)

```gdscript
class_name WandData extends Resource

@export var slot_count: int = 6
@export var mana_max: float = 100.0
@export var mana_regen: float = 20.0        # por segundo
@export var cast_delay: float = 0.15        # entre passos
@export var recharge_delay: float = 0.5     # ao fim do ciclo
@export var base_spread_degrees: float = 0.0
@export var shuffle: bool = false           # opcional, estilo Noita
```

### 4.3 `StatBlock` (acúmulo de modificadores)

```gdscript
class_name StatBlock extends RefCounted

var add: Dictionary[StringName, float] = {}
var mult: Dictionary[StringName, float] = {}
var flags: Dictionary[StringName, bool] = {}

func absorb(spell: SpellData) -> void:
	for k in spell.add_mods:
		add[k] = add.get(k, 0.0) + spell.add_mods[k]
	for k in spell.mult_mods:
		mult[k] = mult.get(k, 1.0) * spell.mult_mods[k]
	for f in spell.flags:
		flags[f] = true

## Pipeline único: (base + soma) * produto
func resolve(stat: StringName, base: float) -> float:
	return (base + add.get(stat, 0.0)) * mult.get(stat, 1.0)

func has_flag(f: StringName) -> bool:
	return flags.get(f, false)
```

### 4.4 `CastNode` (árvore compilada)

```gdscript
class_name CastNode extends RefCounted

var spell: SpellData                  # null em nó de grupo puro
var stats := StatBlock.new()
var children: Array[CastNode] = []    # preenchido em MULTICAST
var spread_degrees: float = 0.0
var event: StringName = &""           # &"on_hit" | &"on_timer" | &""
var event_time: float = 0.0
var payload: CastNode = null
var own_cost: float = 0.0             # magia + modificadores aplicados nela

func total_cost() -> float:
	var c := own_cost
	for ch in children:
		c += ch.total_cost()
	if payload != null:
		c += payload.total_cost()
	return c

func first_leaf() -> CastNode:
	if children.is_empty():
		return self
	return children[0].first_leaf()

func attach(trigger_spell: SpellData, p: CastNode) -> void:
	event = &"on_hit" if trigger_spell.kind == SpellData.Kind.TRIGGER else &"on_timer"
	event_time = trigger_spell.timer_seconds
	payload = p
	own_cost += trigger_spell.mana_cost
```

---

## 5. Gramática de composição

Notação EBNF. `unit` é o que um passo de cast consome.

```
wand        := { unit }
unit        := { MODIFIER } core
core        := PROJECTILE
             | MULTICAST unit{N}              # N = multicast_count
             | (TRIGGER | TIMER) unit unit    # 1º = portador, 2º = carga
```

**Regras de semântica (decisões de design, mudáveis):**

1. **Modificadores aplicam à unidade inteira seguinte.** Antes de um multicast → afetam todos os filhos. Antes de um trigger → afetam só o portador, **não** a carga.
2. **Trigger/Timer em um grupo** anexa ao primeiro projétil-folha (`first_leaf`).
3. **Slot vazio** é ignorado (pulado).
4. **Unidade incompleta** (ex.: multicast sem projéteis suficientes depois dele, trigger sem carga) **degrada com graça**: usa o que existir; se não restar nada, retorna `null`.
5. **Profundidade máxima de compilação** `MAX_DEPTH = 4` para impedir aninhamento absurdo.
6. **Modificador sem projétil depois dele** é descartado, sem custo de mana.

### Exemplos

| Slots | Resultado |
|---|---|
| `[Fogo]` | 1 bola de fogo |
| `[Dano+, Fogo]` | 1 bola de fogo com dano maior |
| `[Multi2, Fogo, Gelo]` | fogo e gelo no mesmo passo, em leque |
| `[Dano+, Multi2, Fogo, Gelo]` | os dois com dano+ |
| `[Trigger, Fogo, Raio]` | fogo; ao acertar, solta raio |
| `[Trigger, Fogo, Multi3, Gelo, Gelo, Gelo]` | fogo; ao acertar, 3 gelos |
| `[Dano+, Trigger, Fogo, Raio]` | fogo com dano+; raio **sem** dano+ |

---

## 6. Compilador de slots

Descida recursiva. Retorna o nó e o índice do próximo slot não consumido.

```gdscript
class_name SpellCompiler extends RefCounted

const MAX_DEPTH := 4

class ParseResult:
	var node: CastNode
	var next: int
	func _init(n: CastNode, i: int) -> void:
		node = n
		next = i

## Compila uma unidade começando em `start`.
static func compile_step(slots: Array[SpellData], start: int) -> ParseResult:
	var none: Array[SpellData] = []
	return _parse_unit(slots, start, none, 0)

## Compila a varinha inteira em uma lista de passos (cache).
static func compile_wand(slots: Array[SpellData]) -> Array[ParseResult]:
	var steps: Array[ParseResult] = []
	var i := 0
	while i < slots.size():
		var r := compile_step(slots, i)
		if r == null:
			break
		steps.append(r)
		i = r.next
	return steps

static func _parse_unit(
		slots: Array[SpellData], i: int,
		pending: Array[SpellData], depth: int) -> ParseResult:
	if depth > MAX_DEPTH:
		return null
	# pula slots vazios
	while i < slots.size() and slots[i] == null:
		i += 1
	if i >= slots.size():
		return null

	var s := slots[i]
	match s.kind:
		SpellData.Kind.MODIFIER:
			var p := pending.duplicate()
			p.append(s)
			return _parse_unit(slots, i + 1, p, depth)

		SpellData.Kind.PROJECTILE:
			return ParseResult.new(_make_leaf(s, pending), i + 1)

		SpellData.Kind.MULTICAST:
			var group := CastNode.new()
			group.spell = s
			group.spread_degrees = s.spread_degrees
			group.own_cost = s.mana_cost + _sum_cost(pending)
			var cursor := i + 1
			for k in s.multicast_count:
				var r := _parse_unit(slots, cursor, pending, depth + 1)
				if r == null:
					break
				group.children.append(r.node)
				cursor = r.next
			if group.children.is_empty():
				return null
			return ParseResult.new(group, cursor)

		SpellData.Kind.TRIGGER, SpellData.Kind.TIMER:
			var carrier := _parse_unit(slots, i + 1, pending, depth + 1)
			if carrier == null:
				return null
			var none: Array[SpellData] = []
			var load := _parse_unit(slots, carrier.next, none, depth + 1)
			if load == null:
				return carrier  # sem carga: ignora o trigger
			carrier.node.first_leaf().attach(s, load.node)
			return ParseResult.new(carrier.node, load.next)

	return null

static func _make_leaf(s: SpellData, pending: Array[SpellData]) -> CastNode:
	var n := CastNode.new()
	n.spell = s
	n.stats.absorb(s)  # modifiers do próprio projétil, se houver
	for m in pending:
		n.stats.absorb(m)
	n.own_cost = s.mana_cost + _sum_cost(pending)
	return n

static func _sum_cost(mods: Array[SpellData]) -> float:
	var c := 0.0
	for m in mods:
		c += m.mana_cost
	return c
```

**Notas:**

- `Array.duplicate()` em array tipado preserva o tipo no Godot 4. Se o parser reclamar na sua build, troque por `var p: Array[SpellData] = pending.duplicate()`.
- Compile **uma vez** quando os slots mudam (`rebuild()`), não a cada clique.
- Uma varinha com `[Fogo, Gelo, Raio]` gera 3 passos; o jogador dispara um por clique, em ordem, e o cursor volta ao início ao fim do ciclo.

---

## 7. Máquina de estados da varinha

```
        clique && mana >= custo
READY ───────────────────────────► CASTING (cooldown = cast_delay)
  ▲                                    │ cooldown <= 0
  │                                    ▼
  │            cursor >= nº passos   se fim do ciclo
  └──────────────────────────────── RECHARGING (cooldown = recharge_delay)
```

- **Mana insuficiente:** o cast **não acontece e o cursor não avança**. (Alternativa de design: pagar parcial e disparar só até onde a mana alcança. Escolha uma e documente.)
- **Regen de mana** roda sempre, em `_process`.
- Stats que alteram delay (`cast_delay`) são lidos do `StatBlock` do nó disparado: `stats.resolve(&"cast_delay", wand.cast_delay)`.

```gdscript
class_name Wand extends Node2D

signal mana_changed(current: float, maximum: float)
signal cast_fired(step_index: int)

@export var data: WandData
var slots: Array[SpellData] = []

var _steps: Array[SpellCompiler.ParseResult] = []
var _cursor := 0
var _mana := 0.0
var _cooldown := 0.0

func _ready() -> void:
	slots.resize(data.slot_count)
	_mana = data.mana_max
	rebuild()

func set_slot(index: int, spell: SpellData) -> void:
	slots[index] = spell
	rebuild()

func rebuild() -> void:
	_steps = SpellCompiler.compile_wand(slots)
	_cursor = 0

func _process(delta: float) -> void:
	_mana = minf(_mana + data.mana_regen * delta, data.mana_max)
	mana_changed.emit(_mana, data.mana_max)
	_cooldown = maxf(_cooldown - delta, 0.0)

func try_cast(aim: Vector2, world: Node) -> bool:
	if _cooldown > 0.0 or _steps.is_empty():
		return false
	var step := _steps[_cursor]
	var cost := step.node.total_cost()
	if _mana < cost:
		return false

	_mana -= cost
	var ctx := CastContext.new()
	ctx.origin = global_position
	ctx.direction = aim.normalized()
	ctx.world = world
	ctx.base_spread = data.base_spread_degrees
	SpellExecutor.fire(step.node, ctx)
	cast_fired.emit(_cursor)

	_cursor += 1
	if _cursor >= _steps.size():
		_cursor = 0
		_cooldown = data.recharge_delay
	else:
		_cooldown = data.cast_delay
	return true
```

---

## 8. Execução

### 8.1 `CastContext`

```gdscript
class_name CastContext extends RefCounted

const MAX_RUNTIME_DEPTH := 4

var origin: Vector2
var direction: Vector2
var world: Node
var base_spread: float = 0.0
var depth: int = 0
var owner_body: Node = null       # para não acertar o próprio jogador
var global_mods: StatBlock = null # relíquias/personagem

func derive(new_origin: Vector2, new_dir: Vector2) -> CastContext:
	var c := CastContext.new()
	c.origin = new_origin
	c.direction = new_dir
	c.world = world
	c.base_spread = 0.0
	c.depth = depth + 1
	c.owner_body = owner_body
	c.global_mods = global_mods
	return c
```

### 8.2 `SpellExecutor`

```gdscript
class_name SpellExecutor extends RefCounted

const MAX_PROJECTILES := 300

static func fire(node: CastNode, ctx: CastContext) -> void:
	if ctx.depth > CastContext.MAX_RUNTIME_DEPTH:
		return
	if node.children.is_empty():
		_spawn(node, ctx, 0.0)
		return

	# grupo (multicast): distribui em leque centrado na direção da mira
	var n := node.children.size()
	for i in n:
		var offset := 0.0
		if n > 1:
			offset = lerpf(-node.spread_degrees, node.spread_degrees, float(i) / (n - 1))
		fire_child(node.children[i], ctx, offset)

static func fire_child(child: CastNode, ctx: CastContext, offset_deg: float) -> void:
	if child.children.is_empty():
		_spawn(child, ctx, offset_deg)
	else:
		# multicast aninhado: aplica o offset ao grupo todo
		var rotated := ctx.derive(ctx.origin, ctx.direction.rotated(deg_to_rad(offset_deg)))
		rotated.depth = ctx.depth  # não conta como nível de trigger
		fire(child, rotated)

static func _spawn(node: CastNode, ctx: CastContext, offset_deg: float) -> void:
	if ctx.world.get_tree().get_nodes_in_group(&"spell_projectiles").size() >= MAX_PROJECTILES:
		return
	var scene := node.spell.projectile_scene
	if scene == null:
		return
	var p := scene.instantiate() as SpellProjectile
	ctx.world.add_child(p)
	p.global_position = ctx.origin
	var jitter := randf_range(-ctx.base_spread, ctx.base_spread)
	var dir := ctx.direction.rotated(deg_to_rad(offset_deg + jitter))
	p.setup(node, ctx, dir)
```

### 8.3 `SpellProjectile`

```gdscript
class_name SpellProjectile extends Area2D

var node: CastNode
var ctx: CastContext
var velocity := Vector2.ZERO
var damage := 0.0
var pierce_left := 0
var bounce_left := 0
var _life := 0.0

func setup(n: CastNode, c: CastContext, dir: Vector2) -> void:
	node = n
	ctx = c
	add_to_group(&"spell_projectiles")
	var s := n.stats
	var sp := n.spell
	damage = s.resolve(&"damage", sp.base_damage)
	var speed := s.resolve(&"speed", sp.base_speed)
	_life = s.resolve(&"lifetime", sp.base_lifetime)
	pierce_left = int(s.resolve(&"pierce", 0.0))
	bounce_left = int(s.resolve(&"bounce", 0.0))
	velocity = dir * speed
	rotation = dir.angle()

	if node.payload != null and node.event == &"on_timer":
		get_tree().create_timer(node.event_time).timeout.connect(_on_timer_event)

	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == ctx.owner_body:
		return
	if body.has_method(&"take_damage"):
		body.take_damage(damage)
	_fire_payload(&"on_hit")
	if pierce_left > 0:
		pierce_left -= 1
		return
	queue_free()

func _on_timer_event() -> void:
	if not is_inside_tree():
		return
	_fire_payload(&"on_timer")
	queue_free()

func _fire_payload(event_name: StringName) -> void:
	if node.payload == null or node.event != event_name:
		return
	var child_ctx := ctx.derive(global_position, velocity.normalized())
	SpellExecutor.fire(node.payload, child_ctx)
```

**Cuidados:**

- Se o payload for disparado por `on_hit` com **pierce**, ele dispara em cada acerto. Decida se isso é desejado ou se deve disparar uma única vez (`_payload_used`).
- Criar nós dentro de `body_entered` (física) pode gerar erro de "flushing queries". Use `call_deferred` em `SpellExecutor.fire` se isso ocorrer.
- Flags como `homing` e `bounce` entram em `_physics_process` e na colisão, lendo `node.stats.has_flag(&"homing")`.

---

## 9. Pipeline de stats (ordem de aplicação)

Um único caminho, sem exceções:

```
valor_final = (base_da_magia + Σ aditivos[varinha, mods, personagem]) × Π multiplicadores[mods, personagem, relíquias]
```

| Etapa | Fonte | Observação |
|---|---|---|
| 1. Base | `SpellData.base_*` | |
| 2. Aditivos | modificadores da unidade, depois personagem | somados |
| 3. Multiplicadores | modificadores da unidade, depois personagem/relíquias | multiplicados (não somados) |
| 4. Clamp | limites duros por stat | evita dano negativo, velocidade infinita |

Para incluir bônus globais, faça `n.stats.absorb_block(ctx.global_mods)` em `_make_leaf` ou no `setup`. **Não** reaplique em cada payload sem decidir se o bônus global vale para a carga também.

---

## 10. Casos de borda

| Caso | Comportamento recomendado |
|---|---|
| Varinha vazia | `try_cast` retorna `false` |
| Só modificadores, sem projétil | nenhum passo compilado |
| Multicast N, só M<N projéteis restantes | dispara M |
| Multicast dentro de multicast | permitido até `MAX_DEPTH` |
| Trigger sem carga | vira projétil comum |
| Trigger dentro de carga de trigger | permitido, limitado por `MAX_RUNTIME_DEPTH` |
| Portador morre por tempo (`lifetime`) sem acertar | trigger `on_hit` **não** dispara (decisão; Noita dispara `expiration` separado) |
| Mana insuficiente no meio de um ciclo | não casta, cursor parado |
| Trocar slot durante o cooldown | `rebuild()` zera o cursor; cooldown continua |
| Limite de projéteis atingido | novos spawns são ignorados |

---

## 11. Performance

- **Compile uma vez.** `rebuild()` só em mudança de slot.
- **Pooling** de projéteis (`Array[SpellProjectile]` por cena). Com recursão de triggers, o número de projéteis cresce exponencialmente.
- **Limites duros:** `MAX_DEPTH` (compilação), `MAX_RUNTIME_DEPTH` (execução), `MAX_PROJECTILES` (global).
- `get_nodes_in_group(...).size()` aloca array; troque por um contador estático incrementado no `setup` e decrementado em `_exit_tree` quando virar gargalo.
- **Custo de mana como freio natural:** o `total_cost()` da árvore inteira impede combos infinitos de graça.

---

## 12. UI do editor de varinha

- Grade de slots com drag and drop (`Control` + `_get_drag_data` / `_can_drop_data` / `_drop_data`).
- **Preview ao vivo:** a cada mudança, chame `SpellCompiler.compile_wand` e mostre:
  - número de passos
  - custo de mana por passo
  - árvore resumida (ex.: `Fogo → [on_hit] → 3× Gelo`)
- Slots que ficam sem uso (modificador sem alvo) devem ser sinalizados visualmente.
- Tooltip da magia mostra os stats resolvidos, não os brutos.

---

## 13. Balanceamento

- **Modelo de custo:** `custo ≈ k × (dano_efetivo × nº_projéteis × fator_utilidade)`. Calibre `k` com a magia mais básica.
- Modificadores fortes devem custar mana ou ocupar slot (já ocupam, por definição).
- Multicast e trigger são os **multiplicadores de poder**; controle-os com custo, spread e limite de profundidade.
- Planilha: uma linha por magia, colunas dano/seg, custo, alcance, utilidade. Simule combos comuns antes de lançar.
- Crie 3 varinhas "de referência" para testes de balanceamento (dano focado, enxame, trigger em cadeia).

---

## 14. Testes

Teste o **compilador** isoladamente (é puro, sem cenas). Com GUT:

```gdscript
extends GutTest

func _spell(kind: SpellData.Kind, cost := 1.0) -> SpellData:
	var s := SpellData.new()
	s.kind = kind
	s.mana_cost = cost
	return s

func test_trigger_attaches_payload_to_carrier() -> void:
	var slots: Array[SpellData] = [
		_spell(SpellData.Kind.TRIGGER),
		_spell(SpellData.Kind.PROJECTILE),
		_spell(SpellData.Kind.PROJECTILE),
	]
	var steps := SpellCompiler.compile_wand(slots)
	assert_eq(steps.size(), 1)
	assert_not_null(steps[0].node.payload)
	assert_eq(steps[0].node.event, &"on_hit")

func test_modifier_does_not_leak_into_payload() -> void:
	var mod := _spell(SpellData.Kind.MODIFIER)
	mod.add_mods = {&"damage": 5.0}
	var slots: Array[SpellData] = [
		mod,
		_spell(SpellData.Kind.TRIGGER),
		_spell(SpellData.Kind.PROJECTILE),
		_spell(SpellData.Kind.PROJECTILE),
	]
	var node := SpellCompiler.compile_wand(slots)[0].node
	assert_eq(node.stats.add.get(&"damage", 0.0), 5.0)
	assert_eq(node.payload.stats.add.get(&"damage", 0.0), 0.0)
```

Casos mínimos a cobrir: varinha vazia, só modificadores, multicast incompleto, trigger sem carga, profundidade máxima, custo total, slots vazios no meio.

---

## 15. O que conferir na wiki do Magicraft

Antes de copiar números ou regras, verifique:

1. Como o Magicraft trata **mana**: custo por magia, por varinha, ou só regen?
2. Existe **cast delay por magia** ou só da varinha?
3. Como funcionam os **multicasts** e quantos disparos simultâneos existem?
4. Os modificadores afetam **todas** as magias seguintes ou só a próxima?
5. Como os **triggers/timers** herdam modificadores (a carga recebe ou não)?
6. Existem **formações** e como alteram o spawn?
7. Qual é o papel de **relíquias, cajados e passivas** no pipeline de stats?
8. Há **limite de slots** e **tipos de varinha** com regras próprias?

Registre as respostas na seção 5 (semântica) e ajuste o compilador.

---

## 16. Roadmap

| Fase | Entrega | Critério de pronto |
|---|---|---|
| **1 — Núcleo** | `SpellData`, `WandData`, `Wand` casta 1 projétil, mana, cast/recharge delay | Clique dispara; mana consome e regenera |
| **2 — Modificadores** | `StatBlock`, 5 modificadores, compilador sem multicast | Dano+/velocidade+/pierce funcionando e testados |
| **3 — Multicast** | Grupo de N, leque, custo agregado | `[Multi2, A, B]` dispara os dois no mesmo passo |
| **4 — Trigger/Timer** | Payload, contexto derivado, limites de profundidade | `[Trigger, A, B]` funciona e não explode |
| **5 — UI** | Editor drag and drop com preview | Montar varinha sem tocar no inspector |
| **6 — Conteúdo e balanceamento** | 20+ magias, 3 varinhas de referência | Combos testados em planilha |
| **7 — Polimento** | Pooling, VFX, SFX, relíquias | 60 FPS com 200+ projéteis |

**Ordem obrigatória:** compilador e testes (fases 2 a 4) antes de qualquer UI. Se a gramática estiver errada, a UI vira retrabalho.

---

## 17. Decisões em aberto (preencha)

- [ ] Mana insuficiente: bloqueia o cast ou paga parcial?
- [ ] Modificadores valem para a carga do trigger? (padrão aqui: não)
- [ ] Trigger dispara a cada acerto com pierce, ou uma vez?
- [ ] Portador que expira por tempo dispara a carga?
- [ ] `consumes_next > 1` (modificadores "todas as seguintes") entra no MVP?
- [ ] Varinha com `shuffle`?
- [ ] Multicast aninhado: o spread soma ou se sobrepõe?
