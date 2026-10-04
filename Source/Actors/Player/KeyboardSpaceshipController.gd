class_name KeyboardSpaceshipController
extends Node

## Controller that maps keyboard input actions to a [SpaceShip2D] instance.

## The spaceship instance that receives thrust and rotation commands.
@export var spaceship: SpaceShip2D

## Group for keyboard input actions.
@export_group("KeyActions","action")

## Input action name used to start the ship's thrust.
@export var action_thrust: StringName = GameConfig.ACTION_THRUST

## Input action name used to turn the ship to the left.
@export var action_turn_left: StringName = GameConfig.ACTION_TURN_LEFT

## Input action name used to turn the ship to the right.
@export var action_turn_right: StringName = GameConfig.ACTION_TURN_RIGHT

## Handles unhandled input events and forwards thrust/turn commands to the spaceship.
## Processes input actions for thrust and turning, calling appropriate spaceship methods.
## @param event The input event to process
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action_thrust):
		Log.debug(&"input", "Thrust pressed", {"action": String(action_thrust)})
		spaceship.start()
	elif event.is_action_released(action_thrust):
		Log.debug(&"input", "Thrust released", {"action": String(action_thrust)})
		spaceship.stop()
	
	if event.is_action_pressed(action_turn_left):
		Log.debug(&"input", "Turn left pressed", {"action": String(action_turn_left)})
		spaceship.turn_left()
	
	if event.is_action_pressed(action_turn_right):
		Log.debug(&"input", "Turn right pressed", {"action": String(action_turn_right)})
		spaceship.turn_right()
	
## Stops ship spinning when no turn input is active.
## Guarded by angular_direction so stop_spin() (and its log) fires once per
## release instead of every physics frame.
func _physics_process(_delta: float) -> void:
	if not Input.is_action_pressed(action_turn_left) and not Input.is_action_pressed(action_turn_right):
		if spaceship.angular_direction != 0.0:
			spaceship.stop_spin()
		
