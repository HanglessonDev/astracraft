## Suite de testes para Bullet2D: garante que a bala viaja na direcao da rotacao.
## Regressao: translate() em espaco local aplicava a rotacao 2x, entao com a
## nave virada para a esquerda (180 graus) a bala saia para a direita.
extends GdUnitTestSuite

const __source := "res://Source/Systems/Weapon/Bullet2D.gd"
const DELTA := 1.0 / 60.0
const APPROX := 0.01


func _make_bullet(rotation_rad: float) -> Bullet2D:
	var bullet := auto_free(Bullet2D.new()) as Bullet2D
	add_child(bullet)
	bullet.global_position = Vector2.ZERO
	bullet.global_rotation = rotation_rad
	return bullet


func test_moves_right_when_facing_right() -> void:
	# Arrange
	var bullet := _make_bullet(0.0)

	# Act
	bullet._physics_process(DELTA)

	# Assert
	var expected := Vector2.RIGHT * bullet.speed * DELTA
	assert_float(bullet.global_position.x).is_equal_approx(expected.x, APPROX)
	assert_float(bullet.global_position.y).is_equal_approx(expected.y, APPROX)


func test_moves_left_when_facing_left() -> void:
	# Arrange — cenario do bug reportado (nave virada para a esquerda)
	var bullet := _make_bullet(PI)

	# Act
	bullet._physics_process(DELTA)

	# Assert — x deve ser NEGATIVO (para a esquerda)
	var expected := Vector2.LEFT * bullet.speed * DELTA
	assert_float(bullet.global_position.x).is_equal_approx(expected.x, APPROX)
	assert_float(bullet.global_position.y).is_equal_approx(expected.y, APPROX)
	assert_bool(bullet.global_position.x < 0.0).is_true()


func test_direction_matches_rotation(
	angle: float, expected_dir: Vector2,
	test_parameters := [
		[0.0, Vector2.RIGHT],
		[PI / 2.0, Vector2.DOWN],
		[PI, Vector2.LEFT],
		[-PI / 2.0, Vector2.UP],
	]
) -> void:
	# Arrange
	var bullet := _make_bullet(angle)

	# Act
	bullet._physics_process(DELTA)

	# Assert
	var expected: Vector2 = expected_dir * bullet.speed * DELTA
	assert_float(bullet.global_position.x).is_equal_approx(expected.x, APPROX)
	assert_float(bullet.global_position.y).is_equal_approx(expected.y, APPROX)
