## Node2D that spawns instances of packed scenes at specific positions.
## Handles finding appropriate containers and positioning spawned objects.
class_name Spawner2D
extends Node2D


## Signal emitted when a new product is successfully created.
signal created(product: Node2D)

## Packed scene to be spawned.
@export var product_packed_scene: PackedScene

## Explicit container for spawned products (a Node2D in the level, ex.: "Bullets").
## Highest priority in [method _resolve_container] — no name lookup involved.
@export var container: Node


## Creates and spawns a new instance of the configured packed scene.
## The product is added to the resolved container (see [method _resolve_container]),
## keeping this spawner's global position and rotation so the product starts
## independent from moving parents.
## @param _product_packed_scene Optional packed scene to spawn (defaults to configured scene)
## @return The spawned Node2D instance
func create(_product_packed_scene:= product_packed_scene) -> Node2D:
	var product: Node2D = _product_packed_scene.instantiate() as Node2D

	var target := _resolve_container()
	target.add_child(product)
	product.global_position = global_position
	product.global_rotation = global_rotation

	if target == self:
		Log.warn(&"spawner", "Spawned under self; no container or group found", {"scene": _product_packed_scene.resource_path.get_file()})
	else:
		Log.debug(&"spawner", "Product spawned", {"scene": _product_packed_scene.resource_path.get_file(), "container": String(target.get_path())})

	created.emit(product)
	return product


## Resolves where spawned products go, by priority:
## 1. [member container] when explicitly assigned (no lookup, no strings);
## 2. first node in the [constant GameConfig.BULLET_CONTAINER] group;
## 3. the current scene; 4. this node as last resort.
## @return The container node, never null
func _resolve_container() -> Node:
	if container != null:
		return container
	var tree := get_tree()
	if tree == null:
		return self
	var grouped := tree.get_first_node_in_group(GameConfig.BULLET_CONTAINER)
	if grouped != null:
		return grouped
	if tree.current_scene != null:
		return tree.current_scene
	return self
	
