## Suite do DebugConsole: parsing do run() e contratos sem UI.
## Sem cenas de jogo na arvore: alvos resolvem para "sem alvo/sem player".
extends GdUnitTestSuite

const __source := "res://Source/Debug/Console/DebugConsole.tscn"


## Instancia o console na arvore de teste (o _ready precisa dos nos).
## Sem class_name no script (o autoload ocupa o nome global): o retorno
## fica dinamico de proposito — chamadas a run() resolvem em runtime.
## @return Console pronto para run(), liberado sozinho no fim do teste
func _make_console() -> Node:
	var console = auto_free(load(__source).instantiate())
	add_child(console)
	return console


func test_run_empty_returns_empty() -> void:
	# Arrange
	var console = _make_console()
	# Act + Assert
	assert_str(console.run("")).is_equal("")
	assert_str(console.run("   ")).is_equal("")


func test_run_unknown_reports_name() -> void:
	# Arrange
	var console = _make_console()
	# Act
	var out = console.run("frobnicate")
	# Assert — ecoa o nome digitado e aponta o help
	assert_str(out).contains("desconhecido: frobnicate")
	assert_str(out).contains("help")


func test_run_slash_prefix_is_optional() -> void:
	# Arrange
	var console = _make_console()
	# Act + Assert
	assert_str(console.run("/help")).is_equal(console.run("help"))
	assert_str(console.run("\\help")).is_equal(console.run("help"))


func test_help_lists_v1_commands() -> void:
	# Arrange
	var console = _make_console()
	# Act
	var out = console.run("help")
	# Assert
	for cmd in ["hp", "damage", "heal", "pos", "score", "spawn", "tags"]:
		assert_str(out).contains(cmd)


func test_commands_without_target_report_no_target() -> void:
	# Arrange — arvore de teste nao tem player em grupo
	var console = _make_console()
	# Act + Assert
	assert_str(console.run("hp")).is_equal("sem alvo")
	assert_str(console.run("damage 10")).is_equal("sem alvo")
	assert_str(console.run("heal")).is_equal("sem alvo")
	assert_str(console.run("pos")).is_equal("sem alvo")
	assert_str(console.run("spawn")).is_equal("sem player")


func test_commands_validate_args_before_touching_game() -> void:
	# Arrange
	var console = _make_console()
	# Act + Assert — uso, sem efeito colateral
	assert_str(console.run("damage")).is_equal("uso: damage [alvo] <n>")
	assert_str(console.run("damage me")).is_equal("uso: damage [alvo] <n>")
	assert_str(console.run("heal me abc")).is_equal("uso: heal [alvo] [n]")
	assert_str(console.run("score")).is_equal("uso: score <n>")
	assert_str(console.run("spawn abc")).is_equal("uso: spawn [n]")


func test_register_custom_command_roundtrip() -> void:
	# Arrange
	var console = _make_console()
	console.register_command(&"ping", "responde pong",
		func(_args: Array) -> String: return "pong")
	# Act + Assert
	assert_str(console.run("ping")).is_equal("pong")
	assert_str(console.run("help")).contains("ping")


func test_toggle_expands_and_collapses_with_pause() -> void:
	# Arrange
	var console = _make_console()
	assert_bool(console.is_open()).is_false()
	# Act — expande
	console.toggle()
	# Assert — aberto e arvore pausada
	assert_bool(console.is_open()).is_true()
	assert_bool(get_tree().paused).is_true()
	# Act — recolhe
	console.toggle()
	# Assert — fechado e arvore rodando
	assert_bool(console.is_open()).is_false()
	assert_bool(get_tree().paused).is_false()
