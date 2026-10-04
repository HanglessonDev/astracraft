class_name SpaceShip2D
extends RigidBody2D

## A physics-driven 2D spaceship that steers by accelerating its own
## [member linear_velocity] and [member angular_velocity] every physics frame.

## Emitted when the ship starts thrusting forward (see [method start]).
signal thrust_started

## Emitted when the ship stops thrusting (see [method stop]).
signal thrust_stopped

## Linear acceleration in pixels per second squared, applied while thrusting.
@export var linear_acceleration := 800.0

## Angular acceleration in radians per second squared, applied while turning.
@export var angular_acceleration := 10.0

## Current thrust direction in the ship's local space.
## [code]Vector2.ZERO[/code] disables thrust.
var linear_direction := Vector2.ZERO

## Current turn input: positive values rotate clockwise, negative values
## rotate counterclockwise, [code]0.0[/code] stops turning.
var angular_direction := 0.0

## Starts forward thrust, pointing it toward the ship's local right,
## and emits [signal thrust_started].
func start() -> void:
	linear_direction = Vector2.RIGHT
	Log.info(&"ship", "Thrust started")
	thrust_started.emit()

## Stops forward thrust and emits [signal thrust_stopped].
func stop() -> void:
	linear_direction = Vector2.ZERO
	Log.info(&"ship", "Thrust stopped")
	thrust_stopped.emit()

## Sets angular direction to turn left (counter-clockwise).
func turn_left()-> void:
	angular_direction = -1
	Log.debug(&"ship", "Turn left started")

## Sets angular direction to turn right (clockwise).
func turn_right()-> void:
	angular_direction = 1
	Log.debug(&"ship", "Turn right started")

## Stops angular rotation by resetting angular direction to zero.
func stop_spin()-> void:
	angular_direction = 0
	Log.debug(&"ship", "Turn stopped")

## Integrates [member linear_acceleration] and [member angular_acceleration]
## into the body's velocities each physics frame.
func _physics_process(delta: float) -> void:
	linear_velocity += (linear_direction * (linear_acceleration * delta)).rotated(rotation)
	angular_velocity += angular_direction * (angular_acceleration * delta)
