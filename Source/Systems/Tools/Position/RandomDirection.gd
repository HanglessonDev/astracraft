## Randomizes a 2D direction around Vector2.RIGHT within a spread.
## Utility for spawn scatter, wander jitter and muzzle variation.
## Emits signals per roll; also returns the direction for direct use.
class_name RandomDirection
extends Node


## Emitted after each roll with the randomized direction.
signal direction_randomized(new_direction: Vector2)
## Emitted after each roll with the applied angle in radians.
signal angle_randomized(new_angle: float)

## Half-spread in degrees around Vector2.RIGHT (0 = always RIGHT).
@export_range(0.0, 180.0) var spread_in_degrees := 0.0


## Rolls a direction inside the configured spread.
## @return Randomized direction vector
func randomize_direction() -> Vector2:
	var angle := deg_to_rad(randf_range(-spread_in_degrees, spread_in_degrees))
	var direction := Vector2.RIGHT.rotated(angle)

	direction_randomized.emit(direction)
	angle_randomized.emit(angle)

	return direction
