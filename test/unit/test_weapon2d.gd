## Suite de testes para Weapon2D: trava o suporte a multiplas armas.
## Cada instancia carrega seu proprio Timer + Spawner2D (vindos da cena),
## entao N armas disparam com cadencia/estado independentes num container
## compartilhado. Tecnica: instanciar a cena real em vez de mockar.
extends GdUnitTestSuite

const __source := "res://Source/Systems/Weapon/Weapon2D.gd"
const WEAPON_SCENE := "res://Source/Systems/Weapon/Weapon2D.tscn"
const BULLET_SCENE := "res://Source/Prefabs/Bullets/DevBullet2D.tscn"
const APPROX := 0.01

var _level: Node2D
var _bullets: Node2D
var _mount_left: Node2D
var _mount_right: Node2D
var _weapon_left: Weapon2D
var _weapon_right: Weapon2D


func before_test() -> void:
	# Arrange — 2 mounts (como as asas da nave) + container no grupo oficial
	_level = auto_free(Node2D.new())
	_level.name = "FakeLevel"
	add_child(_level)

	_bullets = Node2D.new()
	_bullets.name = "Bullets"
	_bullets.add_to_group(GameConfig.BULLET_CONTAINER)
	_level.add_child(_bullets)

	_mount_left = Node2D.new()
	_mount_left.position = Vector2(0, -27)
	_level.add_child(_mount_left)
	_mount_right = Node2D.new()
	_mount_right.position = Vector2(0, 27)
	_level.add_child(_mount_right)

	# Stats proprios por arma: mesma cena, mesma config — como no jogo.
	# (Stats diferentes por mount tambem funcionam; sao so Resources.)
	var stats := WeaponStats.new()
	stats.fire_rate = 5.0
	stats.bullet_packed_scene = load(BULLET_SCENE) as PackedScene

	_weapon_left = _make_weapon(_mount_left, stats)
	_weapon_right = _make_weapon(_mount_right, stats)


func after_test() -> void:
	_bullets.remove_from_group(GameConfig.BULLET_CONTAINER)


## Instancia a cena REAL da arma: vem com Timer + Spawner2D proprios,
## igual ao jogo — e o @onready resolve ao entrar na arvore.
func _make_weapon(mount: Node2D, stats: WeaponStats) -> Weapon2D:
	var packed := load(WEAPON_SCENE) as PackedScene
	var weapon := auto_free(packed.instantiate()) as Weapon2D
	mount.add_child(weapon)
	weapon.weapon_stats = stats
	return weapon


func test_both_weapons_spawn_into_shared_container() -> void:
	# Act — disparo direto (sem esperar Timer: deterministico)
	_weapon_left.fire()
	_weapon_right.fire()

	# Assert — 2 balas, ambas no container compartilhado
	assert_int(_bullets.get_child_count()).is_equal(2)
	for child in _bullets.get_children():
		assert_object(child).is_instanceof(Bullet2D)


func test_mount_offsets_produce_different_positions() -> void:
	# Act
	_weapon_left.fire()
	_weapon_right.fire()

	# Assert — cada bala nasce no seu mount, nao uma em cima da outra
	var left_pos := (_bullets.get_child(0) as Node2D).global_position
	var right_pos := (_bullets.get_child(1) as Node2D).global_position
	assert_float(left_pos.distance_to(right_pos)).is_greater(APPROX)


func test_weapons_keep_independent_state() -> void:
	# Act — liga so a da esquerda
	_weapon_left.start()

	# Assert — a da direita nem percebe
	assert_bool(_weapon_left.firing).is_true()
	assert_bool(_weapon_right.firing).is_false()
	assert_object(_weapon_left.timer).is_not_same(_weapon_right.timer)
	assert_bool(_weapon_left.timer.is_stopped()).is_false()
	assert_bool(_weapon_right.timer.is_stopped()).is_true()
