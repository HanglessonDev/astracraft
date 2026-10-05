## Score award node: grants points to the ScoreSingleton and announces them.
## Trauma (screen-shake budget) derives from points unless overridden.
class_name ScorePoint
extends Node


## Emitted on scoring, carrying points and shake trauma for consumers.
signal scored(points: int, trauma: float)

## Base score value awarded by score().
@export var points := 100

## Fixed trauma override. Negative means derive from points (see trauma_for).
@export var trauma_override := -1.0


## Converts score into shake trauma: sqrt curve, saturating at 1.0.
## Pure function (no nodes), so unit tests cover the tuning directly.
## @param value Score value being awarded
## @return trauma in [0.0, 1.0]
static func trauma_for(value: int) -> float:
	return clampf(sqrt(float(maxi(value, 0))) / 10.0, 0.0, 1.0)


## Awards points and announces them with trauma.
## @param _points Score override (defaults to configured points)
## @return points actually awarded
func score(_points := points) -> int:
	var trauma := trauma_override if trauma_override >= 0.0 else ScorePoint.trauma_for(_points)
	Log.info(&"score", "Scored", {"points": _points, "trauma": trauma})
	ScoreSingleton.increase(_points)
	scored.emit(_points, trauma)
	return _points
