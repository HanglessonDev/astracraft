## Data-driven stats for one asteroid kind: which shapes it uses and how big.
## Shape-agnostic: [member body_shape] and [member hurt_shapes] accept ANY
## Shape2D (circle, rectangle, convex polygon...). One code path serves
## round, rectangular and triangular rocks — the SPIKE question this proves.
class_name AsteroidStats
extends Resource


## Display name (editor pickers and logs).
@export var display_name: StringName = &"Asteroid"

## Shared atlas texture (all asteroids read regions from the same packing).
@export var atlas: Texture2D

## Region inside the atlas (copied from the atlas JSON at authoring time).
## No per-region files: Sprite2D reads texture + rect directly.
@export var region: Rect2

## Optional tint (WHITE = faithful; same art yields variants for free).
@export var modulate: Color = Color.WHITE

## Uniform size multiplier applied to spawned shape nodes.
## Single scalar on purpose: physics only supports uniform scale.
@export var size := 1.0

## The one physics shape (bodies stay cheap with exactly one).
@export var body_shape: Shape2D

## Zero or more detection shapes; no ceiling by design.
@export var hurt_shapes: Array[Shape2D] = []


## Spawns a CollisionShape2D carrying [member body_shape].
## @return configured shape node (caller adds it under the body)
func spawn_body_shape() -> CollisionShape2D:
	var node := CollisionShape2D.new()
	node.shape = body_shape
	node.scale = Vector2(size, size)
	return node


## Spawns one CollisionShape2D per entry in [member hurt_shapes].
## @return shape nodes (caller adds them, e.g. under a HurtArea2D)
func spawn_hurt_shapes() -> Array[CollisionShape2D]:
	var nodes: Array[CollisionShape2D] = []
	for s in hurt_shapes:
		var shape := s as Shape2D
		var node := CollisionShape2D.new()
		node.shape = shape
		node.scale = Vector2(size, size)
		nodes.append(node)
	return nodes
