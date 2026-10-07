## Centralized configuration and helper functions for game teams and groups.
## Provides team detection utilities and avoids magic strings throughout the codebase.
class_name GameConfig
extends RefCounted


## Grupos (add_to_group / is_in_group). Centralizado aqui pra evitar
## strings magicas espalhadas pelas cenas.
## Fronteira com o motor: a API de grupos exige StringName, enum (int)
## nao passa direto — por isso StringName + helpers is_* abaixo.
const PLAYER_TEAM: StringName = &"player_team"
const ENEMY_TEAM: StringName = &"enemy_team"
const HAZARDS: StringName = &"hazards"
const ASTEROIDS: StringName = &"asteroids"

## Group identifying THE player ship node (identity, exactly one).
## Not the same as PLAYER_TEAM (affiliation, N members: a future fleet
## or allied bullet in the team group must never resolve as "the player").
## Used by the debug console as default command target.
const PLAYER_SHIP: StringName = &"player_ship"

## Group identifying enemy ships with AI (identity set, N members).
## Not the same as ASTEROIDS (rocks only) nor ENEMY_TEAM (affiliation):
## a Krustis is never an asteroid, and a future allied drone must never
## resolve as an enemy. Used by the debug console target lookup.
const ENEMIES: StringName = &"enemies"

## Group for the node that collects spawned projectiles (ex.: "Bullets").
## Spawner2D resolves its container through this group — rename the node
## freely, just keep it in the group.
const BULLET_CONTAINER: StringName = &"bullet_container"

## Group for debug nametags (bulk ops are DebugNametag statics).
const DEBUG_NAMETAG: StringName = &"debug_nametag"


## Input actions (Project Settings > Input Map). Use these as defaults for
## exported action names instead of string literals — a typo here fails once,
## loudly, instead of silently breaking input at runtime.
const ACTION_THRUST: StringName = &"thrust"
const ACTION_TURN_LEFT: StringName = &"turn_left"
const ACTION_TURN_RIGHT: StringName = &"turn_right"
const ACTION_FIRE: StringName = &"fire"

## Camadas de UI (z-index centralizado; numero magico espalhado colide).
## Ordem: prompt < transmissao < bussola < rastreador < debug < fade.
const UI_PANEL := 10
const UI_PROMPT := 20
const UI_HUD := 30
const UI_TRANSMISSION := 40
const UI_COMPASS := 50
const UI_TRACKER := 60
const UI_DEBUG := 70
const UI_FADE := 80

## Camadas de fisica 2D (valores de bit, espelham project.godot).
## .tscn nao enxerga consts — os numeros crus continuam la; estas consts
## valem para codigo (masks, raycasts) e como documentacao unica.
## 1 = Ambient, 2 = Combat, 3 = Vision.
const LAYER_AMBIENT := 1
const LAYER_COMBAT := 2
const LAYER_VISION := 4

## Helpers de grupo: prefira eles a is_in_group solto — typo vira erro
## num lugar so, e o call site ganha autocomplete + leitura.
## Checks if a node belongs to the player team.
## @param node The node to check for team membership
## @return true if the node is in the player_team group
static func is_player_team(node: Node) -> bool:
	if node == null:
		Log.warn(&"config", "is_player_team called with null node")
		return false
	return node.is_in_group(PLAYER_TEAM)
	
## Checks if a node belongs to the enemy team.
## @param node The node to check for team membership  
## @return true if the node is in the enemy_team group
static func is_enemy_team(node: Node) -> bool:
	if node == null:
		Log.warn(&"config", "is_enemy_team called with null node")
		return false
	return node.is_in_group(ENEMY_TEAM)
