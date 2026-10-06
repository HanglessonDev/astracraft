## Area2D that receives damage from hit areas.
## Handles damage calculation, defense reduction, and damage events.
class_name HurtArea2D
extends Area2D

## Signal emitted when damage is received, passing the damage taken.
signal damaged(damage_receiveid: int)

## Defense value that reduces incoming damage.
@export var defense:= 0

## Team affiliation for friendly fire checks.
@export var team:= GameConfig.ENEMY_TEAM

##
@export var debug_color: Color = Color(0.204, 0.78, 0.349, 0.502)

##
func _ready() -> void:
	_paint_shapes()

## Calculates and applies damage from a hit.
## @param hit_data The hit data containing damage and team information
## @return The actual damage dealt after defense reduction
func hurt(hit_data:HitData) -> int:
	var damage : =0
	
	damage = hit_data.damage - defense
	Log.debug(&"combat", "Damage calculated", {"raw_damage": hit_data.damage, "defense": defense, "final_damage": damage})
	
	Log.info(&"combat", "Damage received", {"damage": damage})
	damaged.emit(damage)
	return damage

##
func _paint_shapes() -> void:
	for child in self.get_children():
		var shape := child as CollisionShape2D
		if shape:
			shape.debug_color = debug_color
