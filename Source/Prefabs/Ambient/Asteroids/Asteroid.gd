## Root consumer: applies an AsteroidStats to visuals and shapes on ready.
## The stats is the single source of truth; authored scene values are only
## defaults until stats arrive. Size goes to the Visual node only — no other
## code touches scale (shapes follow authored values; RTs propagate Visual).
## In the editor (@tool) only the visual preview runs, deferred past class
## registration; mutations run in game only, so scenes always save clean.
@tool
class_name Asteroid
extends Node2D


## Stats driving visuals, shapes and behavior. Required: without stats the
## asteroid keeps authored scene values and logs a warning.
@export var stats: AsteroidStats

@onready var _visual: Node2D = %Visual
@onready var _sprite: Sprite2D = %Sprite2D
@onready var _collision: CollisionShape2D = %Collision
@onready var _hurt_area: HurtArea2D = %HurtArea2D


## Applies stats once the node enters the tree (children and unique names ready).
func _ready() -> void:
	if stats == null:
		Log.warn(&"asteroid", "Asteroid without stats; keeping authored scene values", {"node": String(name)})
		return
	if Engine.is_editor_hint():
		_apply_visual.call_deferred()
		return
	_apply_visual()
	_apply_collision()
	_apply_hurt()
	_apply_destructible()


## Copies atlas, region, tint and uniform size onto the sprite subtree.
func _apply_visual() -> void:
	_sprite.texture = stats.atlas
	_sprite.region_enabled = true
	_sprite.region_rect = stats.region
	_sprite.modulate = stats.modulate
	_visual.scale = Vector2(stats.size, stats.size)


## Points the body shape at the stats (single cheap shape by design).
func _apply_collision() -> void:
	if stats.body_shape == null:
		Log.warn(&"asteroid", "Stats without body_shape; body stays shapeless", {"stats": String(stats.display_name)})
		return
	_collision.shape = stats.body_shape


## Rebuilds hurt children from the stats array (no ceiling, no leftovers).
func _apply_hurt() -> void:
	for child in _hurt_area.get_children():
		_hurt_area.remove_child(child)
		child.queue_free()
	for shape_node in stats.spawn_hurt_shapes():
		_hurt_area.add_child(shape_node)


## Ambient rocks stay solid but undetectable; destroyables take hits.
func _apply_destructible() -> void:
	_hurt_area.monitorable = stats.destructible
