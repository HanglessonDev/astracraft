## Floating debug nametag: world-space label pinned above an entity.
## Lives as a child of the entity ROOT (never of rotating bodies), so it
## stays upright by construction — no counter-rotation or RemoteTransform.
## Managed in bulk by the DebugNametags autoload (group calls).
class_name DebugNametag
extends Label


## Moving node to follow for position. Defaults to the parent node.
## Point it at the physics body when the entity root itself never moves.
@export var target: Node2D

## Identity source for name and HP (defaults to the parent node).
## Split from target on purpose: position follows movement, identity
## comes from the entity (HP lives next to the root, not the body).
@export var entity: Node

## Vertical offset in pixels (negative floats above).
@export var y_offset := -64.0


func _ready() -> void:
	add_to_group(GameConfig.DEBUG_NAMETAG)
	if target == null:
		target = get_parent() as Node2D
	if entity == null:
		entity = get_parent()


## Refreshes text and position every frame while visible (debug-only cost).
## Rotation is never touched: upright by construction.
func _process(_delta: float) -> void:
	if not visible:
		return
	if target == null or not is_instance_valid(target):
		return
	if entity == null or not is_instance_valid(entity):
		return
	var label := _display_name()
	var resource := _find_resource(entity)
	if resource != null:
		text = "%s %d/%d" % [label, resource.current_amount, resource.max_amount]
	else:
		text = label
	var anchor: Vector2 = get_parent().to_local(target.global_position)
	position = anchor + Vector2(-size.x / 2.0, y_offset)


## Group-callable visibility switch (used by the DebugNametags autoload).
## @param value True to show this tag
func set_tag_visible(value: bool) -> void:
	visible = value


## Prefers a display_name export when the entity has one, else the node name.
## @return label text without HP suffix
func _display_name() -> String:
	var custom: Variant = entity.get("display_name")
	if custom != null:
		return String(custom)
	return entity.name


## Looks for a GameResource among the target's children (one level).
## @param node Entity root to search under
## @return the resource, or null when the entity has no HP (e.g. the player)
func _find_resource(node: Node) -> GameResource:
	for child in node.get_children():
		if child is GameResource:
			return child
	return null
