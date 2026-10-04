## Suite de testes para Spawner2D: garante que o produto nasce no container
## correto e fica independente do parente (nave) que o disparou.
## Regressao: a resolucao por nome de no ("Level"/"Bullets") falhava
## silenciosamente e parentiava a bala no proprio spawner — filho da nave —
## e ela ficava "presa" a rotacao/posicao da nave.
extends GdUnitTestSuite

const __source := "res://Source/Systems/Spawner/Spawner2D.gd"
const BULLET_SCENE := "res://Source/Systems/Weapon/Bullet2D.tscn"
const APPROX := 0.01

var _level: Node2D
var _bullets: Node2D
var _ship: Node2D
var _spawner: Spawner2D


func before_test() -> void:
	# Arrange — mini-hierarquia espelhando Playeground:
	# Level(Bullets, Ship(Spawner2D)), com Bullets no grupo oficial
	_level = auto_free(Node2D.new())
	_level.name = "FakeLevel"
	add_child(_level)

	_bullets = Node2D.new()
	_bullets.name = "Bullets"
	_bullets.add_to_group(GameConfig.BULLET_CONTAINER)
	_level.add_child(_bullets)

	_ship = Node2D.new()
	_ship.name = "FakeShip"
	_level.add_child(_ship)

	_spawner = auto_free(Spawner2D.new())
	_ship.add_child(_spawner)
	_spawner.product_packed_scene = load(BULLET_SCENE) as PackedScene


func after_test() -> void:
	_bullets.remove_from_group(GameConfig.BULLET_CONTAINER)


func test_product_is_parented_to_group_container() -> void:
	# Act — sem export direto: resolve pelo grupo GameConfig.BULLET_CONTAINER
	var product := _spawner.create() as Node2D

	# Assert
	assert_object(product).is_not_null()
	if is_failure():
		return
	assert_object(product.get_parent()).is_same(_bullets)


func test_explicit_container_wins_over_group() -> void:
	# Arrange — container explicito tem prioridade sobre o grupo
	var custom := auto_free(Node2D.new()) as Node2D
	custom.name = "CustomContainer"
	_level.add_child(custom)
	_spawner.container = custom

	# Act
	var product := _spawner.create() as Node2D

	# Assert
	assert_object(product.get_parent()).is_same(custom)


func test_fallback_when_no_container_anywhere() -> void:
	# Arrange — sem export e sem grupo: ultimo recurso documentado
	_bullets.remove_from_group(GameConfig.BULLET_CONTAINER)

	# Act
	var product := _spawner.create() as Node2D

	# Assert — cena atual ou o proprio spawner, nunca erro nem parente movel
	var parent := product.get_parent()
	var ok := parent == _spawner or parent == _spawner.get_tree().current_scene
	assert_bool(ok).is_true()


func test_product_keeps_global_transform_after_ship_moves() -> void:
	# Arrange
	_ship.global_position = Vector2(100, 50)
	_ship.global_rotation = PI / 4.0
	var product := _spawner.create() as Node2D
	var spawn_pos := product.global_position
	var spawn_rot := product.global_rotation

	# Act — a nave sai voando/girando depois do disparo
	_ship.global_position = Vector2(-300, 200)
	_ship.global_rotation = -PI / 2.0

	# Assert — a bala nao acompanha a nave
	assert_float(product.global_position.x).is_equal_approx(spawn_pos.x, APPROX)
	assert_float(product.global_position.y).is_equal_approx(spawn_pos.y, APPROX)
	assert_float(product.global_rotation).is_equal_approx(spawn_rot, APPROX)


func test_product_spawns_with_spawner_global_transform() -> void:
	# Arrange
	_spawner.global_position = Vector2(47, 0)
	_spawner.global_rotation = PI

	# Act
	var product := _spawner.create() as Node2D

	# Assert (angle_difference tolera o wrap PI/-PI, que sao a mesma rotacao)
	assert_float(product.global_position.x).is_equal_approx(47.0, APPROX)
	assert_float(product.global_position.y).is_equal_approx(0.0, APPROX)
	assert_float(angle_difference(product.global_rotation, PI)).is_equal_approx(0.0, APPROX)
