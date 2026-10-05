## Suite do consumidor: Asteroid.gd aplica AsteroidStats na cena.
## Visual, shapes e destructible vêm do dado; a cena dá só a estrutura.
extends GdUnitTestSuite

const __source := "res://Source/Prefabs/Ambient/Asteroids/Asteroid.gd"
const SCENE := "res://Source/Prefabs/Ambient/Asteroids/Asteroid.tscn"
const STATS := "res://Source/Prefabs/Ambient/Asteroids/Data/AsteroidTypeA.tres"


func _make_asteroid() -> Node2D:
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Node2D
	root.set("stats", load(STATS) as AsteroidStats)
	add_child(root)
	return root


func test_applies_visual_from_stats() -> void:
	# Arrange + Act
	var root := _make_asteroid()
	var stats := load(STATS) as AsteroidStats

	# Assert
	var sprite := root.get_node("%Sprite2D") as Sprite2D
	assert_object(sprite.texture).is_same(stats.atlas)
	assert_bool(sprite.region_enabled).is_true()
	assert_bool(sprite.region_rect == stats.region).is_true()


func test_spawns_shapes_from_stats() -> void:
	# Arrange + Act
	var root := _make_asteroid()
	var stats := load(STATS) as AsteroidStats

	# Assert — corpo aponta pro dado, hurt tem exatamente os filhos do array
	var collision := root.get_node("%Collision") as CollisionShape2D
	assert_object(collision.shape).is_same(stats.body_shape)
	var hurt := root.get_node("%HurtArea2D") as HurtArea2D
	assert_int(hurt.get_child_count()).is_equal(stats.hurt_shapes.size())
	assert_object((hurt.get_child(0) as CollisionShape2D).shape).is_same(stats.hurt_shapes[0].get("shape"))


func test_size_applies_to_visual_only() -> void:
	# Arrange + Act (AsteroidTypeA.size = 0.5)
	var root := _make_asteroid()
	var packed := load(SCENE) as PackedScene
	var plain := auto_free(packed.instantiate()) as Node2D
	add_child(plain)

	# Assert — size vai so no Visual; Collision fica como authorado
	var visual := root.get_node("%Visual") as Node2D
	assert_bool(visual.scale == Vector2(0.5, 0.5)).is_true()
	var collision := root.get_node("%Collision") as CollisionShape2D
	var plain_collision := plain.get_node("%Collision") as CollisionShape2D
	assert_bool(collision.scale == plain_collision.scale).is_true()


func test_destructible_gates_detection() -> void:
	# Arrange — AsteroidTypeA é destrutível por padrão
	var root := _make_asteroid()
	var hurt := root.get_node("%HurtArea2D") as HurtArea2D
	assert_bool(hurt.monitorable).is_true()

	# Act — duplicate() para não sujar o resource compartilhado
	var ambient_stats := (load(STATS) as AsteroidStats).duplicate() as AsteroidStats
	ambient_stats.destructible = false
	var packed := load(SCENE) as PackedScene
	var ambient := auto_free(packed.instantiate()) as Node2D
	ambient.set("stats", ambient_stats)
	add_child(ambient)

	# Assert — corpo sólido, detecção desligada
	var ambient_hurt := ambient.get_node("%HurtArea2D") as HurtArea2D
	assert_bool(ambient_hurt.monitorable).is_false()


const ATLAS := "res://Assets/Images/Ambient/asteroid_atlas.png"


func test_missing_stats_keeps_authored_fallback() -> void:
	# Arrange — sem stats: warn + sem crash; cena traz visual authorado padrao
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Node2D

	# Act
	add_child(root)

	# Assert — fallback authorado intacto
	var sprite := root.get_node("%Sprite2D") as Sprite2D
	assert_str(sprite.texture.resource_path).is_equal(ATLAS)
