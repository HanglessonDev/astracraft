## Resource containing hit damage and team information.
## Used to transfer damage data between hit and hurt areas.
class_name HitData
extends Resource


## Damage value to be applied to the target.
@export var damage:= 1

## Team affiliation for friendly fire checks.
@export var team := GameConfig.ENEMY_TEAM
