class_name ScorePoint
extends Node


##
signal scored(value: int)

##
@export var points := 100


##
func score(_points := points) -> int:
	ScoreSingleton.increase(_points)
	scored.emit(_points)
	return _points


func _on_health_resource_depleted() -> void:
	pass # Replace with function body.
