## Suite do consumidor: Asteroid.gd aplica exports na cena.
## Visual, stats e comportamento vêm dos exports; a cena dá a estrutura.
extends GdUnitTestSuite

const __source := "res://Source/Prefabs/Asteroids/Asteroid.gd"
const SCENE := "res://Source/Prefabs/Asteroids/Asteroid.tscn"


func _make_asteroid() -> Asteroid:
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Asteroid
	add_child(root)
	return root


func test_applies_visual_from_exports() -> void:
	# Arrange
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Asteroid
	root.size = 0.5
	root.sprite_modulate = Color(1, 0.5, 0.25)

	# Act
	add_child(root)

	# Assert — size vai so no Visual; resto segue authorado
	var visual := root.get_node("%Visual") as Node2D
	assert_bool(visual.scale == Vector2(0.5, 0.5)).is_true()
	var sprite := root.get_node("%Sprite2D") as Sprite2D
	assert_bool(sprite.modulate == Color(1, 0.5, 0.25)).is_true()
	var collision := root.get_node("%CollisionShape") as CollisionShape2D
	assert_bool(collision.scale == Vector2.ONE).is_true()


func test_injects_health_and_score() -> void:
	# Arrange
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Asteroid
	root.max_hp = 7
	root.score = 25

	# Act
	add_child(root)

	# Assert
	var health := root.get_node("%HealthResource") as GameResource
	assert_int(health.max_amount).is_equal(7)
	assert_int(health.current_amount).is_equal(7)
	var score_point := root.get_node("%ScorePoint") as ScorePoint
	assert_int(score_point.points).is_equal(25)


func test_destructible_off_locks_resource() -> void:
	# Arrange
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Asteroid
	root.destructible = false

	# Act
	add_child(root)

	# Assert — detectável, mas o resource ignora tudo
	var hurt := root.get_node("%HurtArea2D") as HurtArea2D
	assert_bool(hurt.monitorable).is_true()
	var health := root.get_node("%HealthResource") as GameResource
	assert_bool(health.invulnerable).is_true()
	var before: int = health.current_amount
	var hit := HitData.new()
	hit.damage = 99
	hurt.hurt(hit)
	assert_int(health.current_amount).is_equal(before)


func test_lethal_damage_frees_and_scores() -> void:
	# Arrange — flag array (síncrono, imune a free e timing de frames)
	var root := _make_asteroid()
	var hurt := root.get_node("%HurtArea2D") as HurtArea2D
	var score_point := root.get_node("%ScorePoint") as ScorePoint
	var received: Array = []
	score_point.scored.connect(func(points: int, trauma: float) -> void: received.append([points, trauma]))

	# Act — dano letal de uma vez (max_hp default 3)
	var hit := HitData.new()
	hit.damage = 3
	hurt.hurt(hit)
	await get_tree().process_frame

	# Assert — pontos com trauma junto + instância liberada
	assert_int(received.size()).is_equal(1)
	assert_int(int(received[0][0])).is_equal(10)
	assert_bool(is_instance_valid(root)).is_false()


func test_contact_damage_flows_to_hit_area() -> void:
	# Arrange
	var hit_data := HitData.new()
	hit_data.damage = 7
	hit_data.team = GameConfig.ASTEROIDS
	var packed := load(SCENE) as PackedScene
	var root := auto_free(packed.instantiate()) as Asteroid
	root.contact_damage = hit_data

	# Act
	add_child(root)

	# Assert — a gracinha: HitArea do asteroide bate com o dano do export
	var hit_area := root.get_node("%HitArea2D") as HitArea2D
	assert_object(hit_area.hit_data).is_same(hit_data)
