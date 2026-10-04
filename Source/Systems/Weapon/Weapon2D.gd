## Weapon system that fires bullets at configurable rates.
## Handles firing logic, timing, and bullet spawning with fire rate control.
class_name Weapon2D
extends Node2D

## Signal emitted when a bullet is successfully fired.
signal fired
## Signal emitted when weapon starts firing.
signal fire_started
## Signal emitted when weapon stops firing.
signal fire_stopped
## Signal emitted when firing sequence is complete.
signal fired_finished


## Weapon configuration containing fire rate and bullet scene.
@export var weapon_stats: WeaponStats
## Current firing state. When set to true, starts firing sequence.
@export var firing := false : set = set_firing

@onready var timer := %Timer
@onready var spawner := %Spawner2D 


## Sets the firing state and triggers appropriate actions.
## @param new_value True to start firing, false to stop
func set_firing(new_value:bool) -> void:
	firing = new_value
	if firing:
		fire()
	else:
		timer.stop()

## Fires a single bullet and schedules the next shot based on fire rate.
func fire() -> void:
	var bullet := spawner.create(weapon_stats.bullet_packed_scene) as Bullet2D
	bullet.global_rotation = global_rotation
	
	timer.start(1.0 / weapon_stats.fire_rate)
	fired.emit()

## Starts the weapon firing sequence if not already active.
func start() -> void:
	if not timer.is_stopped():
		return
		
	firing = true
	fire_started.emit()

## Stops the weapon firing sequence.
func stop() -> void:
	firing = false
	fire_stopped.emit()

## Called when the firing timer completes. Fires next shot or stops firing.
func _on_timer_timeout() -> void:
	if firing:
		fire()
	else:
		timer.stop()
		fired_finished.emit()
