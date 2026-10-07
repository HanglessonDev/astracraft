## Suite do Krustis: grupo ENEMIES + console hp/damage no inimigo.
## Cresce na TASK-6.4 com o teste de morte.
extends GdUnitTestSuite

const ENEMY := "res://Source/Actors/Enemies/SkotavorKrustis.tscn"
const CONSOLE := "res://Source/Debug/Console/DebugConsole.tscn"


func _make_enemy() -> Node:
	var foe = auto_free(load(ENEMY).instantiate())
	add_child(foe)
	return foe


func _make_console():
	var console = auto_free(load(CONSOLE).instantiate())
	add_child(console)
	return console


func test_enemy_root_is_in_enemies_group() -> void:
	# Arrange + Act
	var foe := _make_enemy() as Node2D
	# Assert — identidade: inimigo com AI nunca e asteroide
	assert_bool(foe.is_in_group(GameConfig.ENEMIES)).is_true()
	assert_bool(foe.is_in_group(GameConfig.ASTEROIDS)).is_false()


func test_console_hp_and_damage_on_enemy() -> void:
	# Arrange
	_make_enemy()
	var console = _make_console()
	# Act + Assert — HP cheio no spawn (replenish no ready)
	assert_str(console.run("hp skotavorkrustis")).is_equal("10/10")
	# Act + Assert — dano passa pela defesa via hurt() real
	assert_str(console.run("damage skotavorkrustis 1")).contains("dano 1")
	assert_str(console.run("hp skotavorkrustis")).is_equal("9/10")


func test_nametag_shows_enemy_hp() -> void:
	# Arrange
	var foe := _make_enemy() as Node2D
	# Act — 1 frame para o _process da tag atualizar o texto
	await get_tree().process_frame
	# Assert
	var tag := foe.find_child("DebugNametag", true, false) as DebugNametag
	assert_str(tag.text).is_equal("SkotavorKrustis 10/10")


func test_lethal_damage_frees_and_scores() -> void:
	# Arrange
	var foe := _make_enemy() as Node2D
	var console = _make_console()
	var saved: int = ScoreSingleton.current_amount
	# Act — dano letal via hurt() real
	console.run("damage skotavorkrustis 10")
	await get_tree().process_frame
	await get_tree().process_frame
	# Assert — no liberado e placar somou
	assert_bool(is_instance_valid(foe)).is_false()
	assert_bool(ScoreSingleton.current_amount > saved).is_true()
	# Cleanup — restaura o placar para os proximos testes
	ScoreSingleton.current_amount = saved
