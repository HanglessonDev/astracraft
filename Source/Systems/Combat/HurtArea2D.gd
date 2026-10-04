## Area2D that receives damage from hit areas.
## Handles damage calculation, defense reduction, and damage events.
class_name HurtArea2D
extends Area2D

## Signal emitted when damage is received, passing the damage taken.
signal damaged(damage_receiveid: int)

## Defense value that reduces incoming damage.
@export var defese:= 0

## Team affiliation for friendly fire checks.
@export var team:= GameConfig.ENEMY_TEAM


## Calculates and applies damage from a hit.
## @param hit_data The hit data containing damage and team information
## @return The actual damage dealt after defense reduction
func hurt(hit_data:HitData) -> int:
	var damage : =0
	
	damage = hit_data.damage - defese
	Log.debug(&"combat", "Damage calculated", {"raw_damage": hit_data.damage, "defense": defese, "final_damage": damage})
	
	Log.info(&"combat", "Damage received", {"damage": damage})
	damaged.emit(damage)
	return damage
