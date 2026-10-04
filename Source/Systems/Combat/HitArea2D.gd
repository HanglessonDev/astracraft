## Area2D that detects collisions and applies damage to hurt areas.
## Handles hit detection, damage calculation, and hit landing events.
class_name HitArea2D
extends Area2D


## Signal emitted when a hit successfully lands, passing the damage dealt.
signal hit_landed(damage)

## Resource containing hit damage and team information.
@export var hit_data: HitData

## Processes a hit when colliding with a hurt area.
## @param hurt_area The hurt area that was hit
func hit(hurt_area: HurtArea2D) -> void:
	if not hurt_area.team == hit_data.team:
		hit_landed.emit(hurt_area.hurt(hit_data))

## Called when an area enters this hit area.
## @param hurt_area The hurt area that entered this hit area
func _on_area_entered(hurt_area: HurtArea2D) -> void:
	hit(hurt_area)


## Called when a hit is successfully landed (placeholder for override).
## Override this method to handle hit landing effects.
func _on_hit_landed() -> void:
	pass # Replace with function body.
