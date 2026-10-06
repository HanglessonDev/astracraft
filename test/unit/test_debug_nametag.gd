## Suite das debug nametags: toggle global via autoload + conteúdo nome + HP.
extends GdUnitTestSuite

const __source := "res://Source/UI/DebugNametag.gd"
const SCENE := "res://Source/UI/DebugNametag.tscn"


func _make_tag(entity_parent: Node) -> DebugNametag:
	var packed := load(SCENE) as PackedScene
	var tag := auto_free(packed.instantiate()) as DebugNametag
	entity_parent.add_child(tag)
	return tag


func test_toggle_hides_and_shows_all_tags() -> void:
	# Arrange
	var holder := auto_free(Node2D.new()) as Node2D
	holder.name = "Holder"
	add_child(holder)
	_make_tag(holder)
	DebugNametags.show_all()

	# Act
	DebugNametags.hide_all()

	# Assert
	for node in get_tree().get_nodes_in_group(GameConfig.DEBUG_NAMETAG):
		assert_bool((node as CanvasItem).visible).is_false()

	# Cleanup — devolve visível para os próximos testes
	DebugNametags.show_all()


func test_content_shows_name_and_hp() -> void:
	# Arrange — entidade com resource de HP
	var holder := auto_free(Node2D.new()) as Node2D
	holder.name = "Scout"
	add_child(holder)
	var resource := GameResource.new()
	resource.max_amount = 10
	resource.current_amount = 3
	holder.add_child(resource)
	auto_free(resource)
	var tag := _make_tag(holder)

	# Act — 1 frame para o _process atualizar o texto
	await get_tree().process_frame

	# Assert
	assert_str(tag.text).is_equal("Scout 3/10")


func test_content_without_hp_shows_name_only() -> void:
	# Arrange — entidade sem resource (ex.: player)
	var holder := auto_free(Node2D.new()) as Node2D
	holder.name = "Player"
	add_child(holder)
	var tag := _make_tag(holder)

	# Act
	await get_tree().process_frame

	# Assert
	assert_str(tag.text).is_equal("Player")


func test_follows_moving_target_keeping_identity() -> void:
	# Arrange — raiz parada (como Player/Asteroid), corpo em movimento
	var holder := auto_free(Node2D.new()) as Node2D
	holder.name = "Mover"
	add_child(holder)
	var body := Node2D.new()
	body.position = Vector2(100, 50)
	holder.add_child(body)
	auto_free(body)
	var tag := _make_tag(holder)
	tag.target = body

	# Act
	await get_tree().process_frame

	# Assert — posição segue o corpo, nome vem da entidade
	var expected := Vector2(100.0 - tag.size.x / 2.0, 50.0 - 64.0)
	assert_bool(tag.global_position.is_equal_approx(expected)).is_true()
	assert_str(tag.text).is_equal("Mover")
