class_name KeyboardWeaponController
extends Node

##
@export var weapons : Array[Weapon2D]
##
@export var fire_input_action_name: StringName = GameConfig.ACTION_FIRE

##
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(fire_input_action_name):
		for weapon in weapons:
			weapon.start()
	elif event.is_action_released(fire_input_action_name):
		for weapon in weapons:
			weapon.stop()
