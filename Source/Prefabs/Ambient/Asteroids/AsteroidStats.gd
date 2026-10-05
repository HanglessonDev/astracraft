## Data-driven stats for one asteroid kind: which shapes it uses and how big.
## Shape-agnostic: [member body_shape] and [member hurt_shapes] accept ANY
## Shape2D (circle, rectangle, convex polygon...). One code path serves
## round, rectangular and triangular rocks — the SPIKE question this proves.
class_name AsteroidStats
extends Resource


## Display name (editor pickers and logs).
@export var display_name: StringName = &"Asteroid"

## When false, this is scenery: solid body, but the hurt area ignores hits.
## Ambient rocks use the same scene and stats with this off.
@export var destructible := true

## Hits taken before death (contact and bullets share the pool).
@export var max_hp := 3

## Damage dealt on body contact (wiring a HitArea is future work).
@export var contact_damage := 1

## Score awarded on death.
@export var score := 10

## Screen-shake trauma emitted on death (the level camera consumes it).
@export var trauma := 0.4

## Explosion FX scale (particles + shockwave ring, spawned by consumers).
@export var explosion_scale := 1.0

## Weight for future random spawn tables (ignored for now).
@export var spawn_weight := 1.0

## Shared atlas texture (all asteroids read regions from the same packing).
@export var atlas: Texture2D

## Region inside the atlas (copied from the atlas JSON at authoring time).
## No per-region files: Sprite2D reads texture + rect directly.
@export var region: Rect2

## Optional tint (WHITE = faithful; same art yields variants for free).
@export var modulate: Color = Color.WHITE

## Uniform size multiplier for the Visual node ONLY. No other code may
## touch scale: shapes follow authored values (RTs propagate the Visual).
## Single scalar on purpose: physics only supports uniform scale.
@export var size := 1.0

## The one physics shape (bodies stay cheap with exactly one).
@export var body_shape: Shape2D

## Zero or more detection shapes; no ceiling by design.
@export var hurt_shapes: Array[HurtShape] = []


## Spawns a CollisionShape2D carrying [member body_shape].
## @return configured shape node (caller adds it under the body)
func spawn_body_shape() -> CollisionShape2D:
	var node := CollisionShape2D.new()
	node.shape = body_shape
	return node


## Debug color for spawned hurt shapes (magenta-ish, distinct from body collision).
const HURT_DEBUG_COLOR := Color(0.863, 0.0, 0.863, 0.42)


## Spawns one CollisionShape2D per entry in [member hurt_shapes].
## @return shape nodes (caller adds them, e.g. under a HurtArea2D)
func spawn_hurt_shapes() -> Array[CollisionShape2D]:
	var nodes: Array[CollisionShape2D] = []
	for entry in hurt_shapes:
		var node := CollisionShape2D.new()
		node.shape = entry.shape
		node.position = entry.offset
		node.debug_color = HURT_DEBUG_COLOR
		nodes.append(node)
	return nodes
