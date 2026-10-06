@tool
class_name Asteroid
extends Node2D

##
## Display name (editor pickers and logs).
@export var display_name: StringName = &"Asteroid"

@export_group("Visual")
##
@export var atlas: SpriteFrames
##
@export var anim_name: StringName = &"default"
##
@export var frame_index:= 0
##
@export var size:= 1.0
## Optional tint (WHITE = faithful; same art yields variants for free).
@export var sprite_modulate: Color = Color.WHITE

##
@export_group("Stats")
## When false, this is scenery: solid body, but the hurt area ignores hits.
## Ambient rocks use the same scene and stats with this off.
@export var destructible := true

## Hits taken before death (contact and bullets share the pool).
@export_range(0, 9999, 1) var max_hp := 3

## Damage dealt on body contact (wiring a HitArea is future work).
@export var contact_damage : HitData

## Score awarded on death. Shake trauma derives from this (see ScorePoint).
@export var score := 10

## Explosion FX scale (particles + shockwave ring, spawned by consumers).
@export var explosion_scale := 1.0

## Weight for future random spawn tables (ignored for now).
@export var spawn_weight := 1.0


@onready var _visual: Node2D = %Visual
@onready var _sprite: Sprite2D = %Sprite2D
@onready var _hurt_area: HurtArea2D = %HurtArea2D
@onready var _hit_area: HitArea2D = %HitArea2D
@onready var _health: GameResource = %HealthResource
@onready var _score: ScorePoint = %ScorePoint

const team: StringName = &"asteroids"

## Applies stats once the node enters the tree (children and unique names ready).
## HP and death live in the wired nodes (HealthResource, ScorePoint);
## this only injects tuned values from 
func _ready() -> void:
	_apply_visual()
	
	if Engine.is_editor_hint():
		return
	
	_apply_stats()

##
func _apply_stats()-> void:
	_health.max_amount = max_hp
	_health.replenish()
	_health.invulnerable = not destructible
	_score.points = score
	_hit_area.hit_data = contact_damage
	_hurt_area.team = team
	

## Copies atlas, region, tint and uniform size onto the sprite subtree.
func _apply_visual() -> void:
	_visual.scale = Vector2(size, size)
	_sprite.texture = atlas.get_frame_texture(anim_name, frame_index)
	_sprite.modulate = sprite_modulate
