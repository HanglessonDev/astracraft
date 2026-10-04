extends GdUnitTestSuite
## Testes do Log: filtro por sink, formatos puros e rotação pequena.
## Estado global restaurado em after_test. APIs conferidas contra o
## addon (lição do assert_vector2i): is_enabled, passes implícito,
## print_rich/print/push e JSON.parse_string existem.

const TEST_PATH := "user://log_test/app.jsonl"

var _saved_console: int
var _saved_file_level: int
var _saved_path: String
var _saved_max_bytes: int
var _saved_max_files: int
var _saved_enabled: bool
var _saved_buffer_max: int


func before_test() -> void:
	_saved_console = Log.console_level
	_saved_file_level = Log.file_level
	_saved_path = Log.file_path
	_saved_max_bytes = Log.max_file_bytes
	_saved_max_files = Log.max_files
	_saved_enabled = Log.file_enabled
	_saved_buffer_max = Log.buffer_max
	Log.close_file()
	Log._buffer.clear()


func after_test() -> void:
	Log.close_file()
	Log._buffer.clear()
	Log.console_level = _saved_console
	Log.file_level = _saved_file_level
	Log.file_path = _saved_path
	Log.max_file_bytes = _saved_max_bytes
	Log.max_files = _saved_max_files
	Log.file_enabled = _saved_enabled
	Log.buffer_max = _saved_buffer_max
	_clean_dir("user://log_test")


func _clean_dir(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		for f in DirAccess.get_files_at(path):
			DirAccess.remove_absolute(path.path_join(f))


func _use_test_file(max_bytes: int = 300, max_files: int = 3) -> void:
	_clean_dir("user://log_test")
	Log.file_enabled = true
	Log.file_path = TEST_PATH
	Log.max_file_bytes = max_bytes
	Log.max_files = max_files
	Log.console_level = Log.Level.DEBUG
	Log.file_level = Log.Level.DEBUG


func test_format_has_level_category_and_message() -> void:
	var line := Log.format_message(Log.Level.INFO, &"tactic", "ordem aceita")
	assert_bool(line.contains("[INFO]")).is_true()
	assert_bool(line.contains("[tactic]")).is_true()
	assert_bool(line.contains("ordem aceita")).is_true()


func test_json_roundtrip() -> void:
	var line := Log.format_json(Log.Level.WARN, &"sector", "borda",
		{"hex": [10, 0]})
	var parsed: Variant = JSON.parse_string(line)
	assert_bool(parsed is Dictionary).is_true()
	assert_str(parsed["lvl"]).is_equal("WARN")
	assert_str(parsed["cat"]).is_equal("sector")
	assert_bool("borda" in parsed["msg"]).is_true()
	assert_array(Array(parsed["data"]["hex"])).is_equal([10.0, 0.0])
	assert_bool(int(parsed["ms"]) >= 0).is_true()


func test_console_filter_hides_debug_but_file_keeps() -> void:
	_use_test_file()
	Log.console_level = Log.Level.INFO
	Log.file_level = Log.Level.DEBUG
	assert_bool(Log.is_enabled(Log.Level.DEBUG)).is_true() # arquivo quer
	assert_bool(Log.is_enabled(Log.Level.INFO)).is_true()
	Log.console_level = Log.Level.WARN
	Log.file_enabled = false
	assert_bool(Log.is_enabled(Log.Level.INFO)).is_false() # ninguém quer
	assert_bool(Log.is_enabled(Log.Level.ERROR)).is_true()


func test_filter_blocks_below_minimum() -> void:
	_use_test_file()
	Log.console_level = Log.Level.WARN
	Log.file_level = Log.Level.WARN
	Log.debug(&"t", "some antes")
	Log.close_file()
	assert_bool(FileAccess.file_exists(TEST_PATH)).is_false()
	Log.info(&"t", "some antes")
	Log.close_file()
	assert_bool(FileAccess.file_exists(TEST_PATH)).is_false()


func test_warn_and_above_reach_file() -> void:
	_use_test_file()
	Log.console_level = Log.Level.WARN
	Log.file_level = Log.Level.WARN
	Log.warn(&"t", "aparece")
	Log.close_file()
	assert_bool(FileAccess.file_exists(TEST_PATH)).is_true()
	var content := FileAccess.get_file_as_string(TEST_PATH)
	assert_bool(JSON.parse_string(content) is Dictionary).is_true()


func test_rotation_caps_total_size() -> void:
	_use_test_file(300, 3)
	Log.console_level = Log.Level.ERROR # suíte limpa: sem print por linha
	Log.file_level = Log.Level.INFO
	for i in range(30):
		Log.info(&"t", "linha de preenchimento numero %d abcdefghij" % i)
	Log.close_file()
	var total := 0
	var count := 0
	for f in DirAccess.get_files_at("user://log_test"):
		count += 1
		total += FileAccess.get_file_as_string(
			"user://log_test".path_join(f)).length()
	assert_bool(count > 1).is_true() # rodou: mais de 1 arquivo
	assert_bool(count <= 3).is_true() # teto: nunca mais que max_files
	assert_bool(total <= 3 * (300 + 200)).is_true() # teto global aproximado


func test_recent_returns_last_n_in_order() -> void:
	_use_test_file()
	Log.console_level = Log.Level.ERROR # suíte limpa: sem print por linha
	for i in range(5):
		Log.info(&"t", "buf %d" % i)
	var tail: Array = Log.recent(3)
	assert_int(tail.size()).is_equal(3)
	assert_str(tail[0]["msg"]).is_equal("buf 2")
	assert_str(tail[2]["msg"]).is_equal("buf 4")
	assert_int(Log.recent(99).size()).is_equal(5) # além do buffer: tudo
	assert_array(Log.recent(0)).is_empty()
	assert_array(Log.recent(-1)).is_empty()


func test_buffer_caps_at_buffer_max() -> void:
	_use_test_file()
	Log.console_level = Log.Level.ERROR # suíte limpa: sem print por linha
	Log.buffer_max = 4
	for i in range(7):
		Log.info(&"t", "cap %d" % i)
	var tail: Array = Log.recent(99)
	assert_int(tail.size()).is_equal(4)
	assert_str(tail[0]["msg"]).is_equal("cap 3") # mais antiga sobrevivente
	assert_str(tail[3]["msg"]).is_equal("cap 6")
