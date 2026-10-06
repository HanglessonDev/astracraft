## Autoload console for debug nametags: stable API for the future debug
## console (show/hide/toggle/query). Operates on the debug_nametag group,
## so tags never need direct references. Hidden in release builds.
extends Node


## Current global visibility state.
var _showing := true


func _ready() -> void:
	_showing = OS.is_debug_build()
	if not _showing:
		hide_all()


## @return true when nametags are currently shown
func is_showing() -> bool:
	return _showing


## Shows every nametag in the tree.
func show_all() -> void:
	_showing = true
	get_tree().call_group(GameConfig.DEBUG_NAMETAG, "set_tag_visible", true)


## Hides every nametag in the tree.
func hide_all() -> void:
	_showing = false
	get_tree().call_group(GameConfig.DEBUG_NAMETAG, "set_tag_visible", false)


## Toggles global nametag visibility.
func toggle() -> void:
	if _showing:
		hide_all()
	else:
		show_all()


## Sets visibility for the tag following one entity (no-op when absent).
## @param entity Entity root whose tag should change
## @param value True to show that tag
func set_entity_visible(entity: Node, value: bool) -> void:
	for node in get_tree().get_nodes_in_group(GameConfig.DEBUG_NAMETAG):
		var tag := node as DebugNametag
		if tag != null and tag.entity == entity:
			tag.set_tag_visible(value)
