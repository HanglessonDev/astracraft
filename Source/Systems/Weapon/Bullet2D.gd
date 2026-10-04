## Simple projectile that moves in a straight line at constant speed.
## Basic bullet implementation with physics-based movement.
class_name Bullet2D
extends Node2D


## Movement speed in pixels per second.
@export var speed := 2000.0

## Updates bullet position each physics frame.
## Moves the bullet forward at the configured speed in global space.
## Uses global_position (not translate) so the direction is applied exactly once.
## @param delta The time elapsed since the previous frame
func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta
