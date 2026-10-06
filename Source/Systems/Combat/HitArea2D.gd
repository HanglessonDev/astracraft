## Area2D that detects collisions and applies damage to hurt areas.
## Handles hit detection, damage calculation, and hit landing events.
class_name HitArea2D
extends Area2D


## Signal emitted when a hit successfully lands, passing the damage dealt.
signal hit_landed(damage)

## Resource containing hit damage and team information.
@export var hit_data: HitData

##
@export var debug_color: Color = Color(1.0, 0.231, 0.188, 0.502)

##
func _ready() -> void:
	_paint_shapes()

## Processes a hit when colliding with a hurt area.
## @param hurt_area The hurt area that was hit
func hit(hurt_area: HurtArea2D) -> void:
	if hurt_area.team == hit_data.team:
		Log.debug(&"combat", "Friendly fire blocked", {"hit_team": String(hit_data.team), "hurt_team": String(hurt_area.team)})
		return
	var damage := hurt_area.hurt(hit_data)
	Log.info(&"combat", "Hit landed", {"damage": damage})
	hit_landed.emit(damage)

## Called when an area enters this hit area.
## Ignores anything that is not a HurtArea2D (e.g. other bullets
## overlapping mid-flight must never trigger nor error).
## @param area The area that entered this hit area
func _on_area_entered(area: Area2D) -> void:
	if area is HurtArea2D:
		hit(area)


## Called when a hit is successfully landed (placeholder for override).
## Override this method to handle hit landing effects.
func _on_hit_landed() -> void:
	pass # Replace with function body.

##
func _paint_shapes() -> void:
	for child in self.get_children():
		var shape := child as CollisionShape2D
		if shape:
			shape.debug_color = debug_color
