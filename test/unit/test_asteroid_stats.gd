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
	assert_object(nodes[0].shape).is_same(stats.hurt_shapes[0])
	assert_object(nodes[1].shape).is_same(stats.hurt_shapes[1])


func test_size_applies_to_spawned_nodes() -> void:
	# Arrange — duplicate() para nao sujar o resource compartilhado entre testes
	var stats := _load_stats("convex").duplicate() as AsteroidStats
	stats.size = 2.0

	# Act
	var node := auto_free(stats.spawn_body_shape()) as CollisionShape2D

	# Assert
	assert_float(node.scale.x).is_equal_approx(2.0, APPROX)
	assert_float(node.scale.y).is_equal_approx(2.0, APPROX)
