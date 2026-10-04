## Specialized hit area for weapons with custom behavior.
## Extends HitArea2D to add weapon-specific hit detection logic.
class_name WeaponHitArea2D
extends HitArea2D


## Called when the node enters the scene tree for the first time.
## Override to initialize weapon-specific hit area properties.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. Override for continuous weapon behavior.
## @param delta The time elapsed since the previous frame
func _process(delta: float) -> void:
	pass
