## Suite do SPIKE: prova que um unico caminho de codigo serve qualquer forma.
## Circle, Rectangle e ConvexPolygon entram pelo mesmo body_shape/hurt_shapes.
extends GdUnitTestSuite

const __source := "res://Source/Prefabs/Ambient/Asteroids/AsteroidStats.gd"
const APPROX := 0.01


func _load_stats(kind: String) -> AsteroidStats:
	return load("res://test/unit/data/asteroid_stats_%s.tres" % kind) as AsteroidStats


func test_circle_body_shape() -> void:
	# Arrange
	var stats := _load_stats("circle")

	# Act
	var node := auto_free(stats.spawn_body_shape()) as CollisionShape2D

	# Assert
	assert_object(node.shape).is_instanceof(CircleShape2D)
	assert_float((node.shape as CircleShape2D).radius).is_equal_approx(50.0, APPROX)


func test_rect_body_shape() -> void:
	# Arrange
	var stats := _load_stats("rect")

	# Act
	var node := auto_free(stats.spawn_body_shape()) as CollisionShape2D

	# Assert — mesmo factory, outra forma: nada de branch por tipo
	assert_object(node.shape).is_instanceof(RectangleShape2D)
	assert_object(node.shape).is_same(stats.body_shape)


func test_convex_body_shape() -> void:
	# Arrange
	var stats := _load_stats("convex")

	# Act
	var node := auto_free(stats.spawn_body_shape()) as CollisionShape2D

	# Assert — triangulo passa pelo mesmo caminho
	assert_object(node.shape).is_instanceof(ConvexPolygonShape2D)
	assert_int((node.shape as ConvexPolygonShape2D).points.size()).is_equal(3)


func test_hurt_shapes_match_array_without_ceiling() -> void:
	# Arrange — circle tem 2, rect tem 1, convex tem 0: quantidade vem do dado
	var stats := _load_stats("circle")

	# Act
	var nodes := stats.spawn_hurt_shapes()
	for n in nodes:
		auto_free(n)

	# Assert
	assert_int(nodes.size()).is_equal(2)
	assert_object(nodes[0].shape).is_same(stats.hurt_shapes[0].get("shape"))
	assert_object(nodes[1].shape).is_same(stats.hurt_shapes[1].get("shape"))
	assert_bool(nodes[0].debug_color == AsteroidStats.HURT_DEBUG_COLOR).is_true()


func test_hurt_shapes_offsets_applied() -> void:
	# Arrange — circle tem 2 hurt shapes com offset zero (migração preserva behavior)
	var stats := _load_stats("circle")

	# Act
	var nodes := stats.spawn_hurt_shapes()
	
	# Assert
	assert_int(nodes.size()).is_equal(2)
	# Prova que offset chega no nó (migração para ZERO preserva behavior atual)
	assert_that(nodes[0].position).is_equal(Vector2.ZERO)
	assert_that(nodes[1].position).is_equal(Vector2.ZERO)
	
	# Limpeza
	for n in nodes:
		auto_free(n)


func test_spawned_nodes_come_unscaled() -> void:
	# Arrange — size vale so para o Visual (regra); factories spawnam sem escala.
	# duplicate() para nao sujar o resource compartilhado entre testes.
	var stats := _load_stats("convex").duplicate() as AsteroidStats
	stats.size = 2.0

	# Act
	var node := auto_free(stats.spawn_body_shape()) as CollisionShape2D
	var hurt := stats.spawn_hurt_shapes()
	for n in hurt:
		auto_free(n)

	# Assert
	assert_bool(node.scale == Vector2.ONE).is_true()
	assert_bool(hurt.is_empty()).is_true()
