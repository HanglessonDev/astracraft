class_name Log
extends RefCounted

## Logging do projeto: níveis por sink, categorias, console humano limpo
## e arquivo JSONL completo (máquina lê arquivo, humano lê console).
## File sink com TETO (rotação por tamanho — nunca mais um log de 9 GB).
## Estático (sem autoload/boot order, chamável até em teste).
##
## Uso: Log.info("tactic", "ordem aceita", {"para": [3, -1]}).
## Categorias: StringName livre por sistema ("move", "tactic", "sector",
## "combat", "ui"). `data` (Dictionary JSON) carrega campos consultáveis;
## tipos precisam ser JSON (string/num/bool/array/dict; Vector2i NÃO —
## converta p/ [x, y] ou str() no chamador).
## DEBUG retorna antes de I/O (mas GDScript avalia args antes da chamada —
## p/ strings caras, cheque Log.is_enabled() antes).
## ERROR/WARN passam por push_error/push_warning (integração do editor;
## o file:line aponta aqui, o backtrace aponta o chamador — tradeoff
## documentado). Nunca logar de dentro dos sinks (recursão, doc).

enum Level { DEBUG, INFO, WARN, ERROR }

const LEVEL_NAMES := ["DEBUG", "INFO", "WARN", "ERROR"]
const LEVEL_COLORS := ["gray", "white", "yellow", "red"]
const DEFAULT_PATH := "user://logs/game.jsonl"

static var console_level: int = Level.INFO
static var file_level: int = Level.DEBUG
static var file_enabled: bool = OS.has_feature("debug")
static var file_path: String = DEFAULT_PATH
static var max_file_bytes: int = 5 * 1024 * 1024
static var max_files: int = 3
static var buffer_max: int = 500 # teto do buffer (console futuro lê daqui)

static var _file: FileAccess
static var _buffer: Array[Dictionary] = []


## True se a mensagem passa em ALGUM sink (guarda p/ strings caras).
static func is_enabled(level: int) -> bool:
	return level >= console_level or (file_enabled and level >= file_level)


static func debug(cat: StringName, msg: String, data: Dictionary = {}) -> void:
	_log(Level.DEBUG, cat, msg, data)


static func info(cat: StringName, msg: String, data: Dictionary = {}) -> void:
	_log(Level.INFO, cat, msg, data)


static func warn(cat: StringName, msg: String, data: Dictionary = {}) -> void:
	_log(Level.WARN, cat, msg, data)


static func error(cat: StringName, msg: String, data: Dictionary = {}) -> void:
	_log(Level.ERROR, cat, msg, data)


## Timestamp único por chamada (correlaciona console × arquivo).
static func _timestamp() -> String:
	var t := Time.get_time_dict_from_system()
	return "%02d:%02d:%02d.%03d" % [
		t["hour"], t["minute"], t["second"],
		int(t["millisecond"]) if t.has("millisecond") else 0]


## Formato humano puro (testável): [HH:MM:SS.mmm][LEVEL][cat] msg.
static func format_message(
	level: int, cat: StringName, msg: String, stamp: String = ""
) -> String:
	var ts := stamp if stamp != "" else _timestamp()
	return "[%s][%s][%s] %s" % [ts, LEVEL_NAMES[level], String(cat), msg]


## Formato máquina puro (testável): 1 objeto JSON por linha.
## `ms` = uptime monotônico (ordenação/deltas exatos; o relógio de parede
## do Godot não tem milissegundo — `t` fica com .000).
static func format_json(
	level: int, cat: StringName, msg: String,
	data: Dictionary = {}, stamp: String = ""
) -> String:
	var ts := stamp if stamp != "" else _timestamp()
	return JSON.stringify({"t": ts, "ms": Time.get_ticks_msec(),
		"lvl": LEVEL_NAMES[level], "cat": String(cat),
		"msg": msg, "data": data})


static func _log(level: int, cat: StringName, msg: String, data: Dictionary) -> void:
	var to_console := level >= console_level
	var to_file := file_enabled and level >= file_level
	if not to_console and not to_file:
		return
	var ts := _timestamp()
	_buffer.append({"t": ts, "ms": Time.get_ticks_msec(),
		"lvl": LEVEL_NAMES[level], "cat": String(cat),
		"msg": msg, "data": data})
	while _buffer.size() > buffer_max:
		_buffer.pop_front()
	if to_console:
		var line := format_message(level, cat, msg, ts)
		match level:
			Level.ERROR:
				push_error(line)
			Level.WARN:
				push_warning(line)
			_:
				print_rich("[color=%s]%s[/color]" % [LEVEL_COLORS[level], line])
	if to_file:
		_write_file(format_json(level, cat, msg, data, ts),
			level >= Level.INFO)


## Últimas n entradas (DRAFT-2 vai consumir daqui). Cópia rasa, seguro.
static func recent(count: int) -> Array:
	if count <= 0:
		return []
	return _buffer.slice(maxi(0, _buffer.size() - count))


static func _write_file(line: String, flush: bool) -> void:
	_write_file_flushed(line, flush)


## Flush só em INFO+ (linhas raras): sobrevive ao Stop do debugger.
## DEBUG de alta frequência não fluscha (custo); perda aceitável.
static func _write_file_flushed(line: String, flush: bool) -> void:
	if not file_enabled:
		return
	_ensure_file()
	if _file == null:
		return
	var payload := line + "\n"
	if _file.get_length() + payload.length() > max_file_bytes:
		_rotate()
		_ensure_file()
		if _file == null:
			return
	_file.store_string(payload)
	if flush:
		_file.flush()


static func _ensure_file() -> void:
	if _file != null:
		return
	var dir := file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		if DirAccess.make_dir_recursive_absolute(dir) != OK:
			return
	if not FileAccess.file_exists(file_path):
		var fresh := FileAccess.open(file_path, FileAccess.WRITE)
		if fresh == null:
			return
		fresh.close()
	_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if _file != null:
		_file.seek_end()


static func _rotate() -> void:
	if _file != null:
		_file.close()
		_file = null
	var base := file_path.get_basename()
	var ext := file_path.get_extension()
	# Apaga o mais antigo, desloca o resto, base vira .1.
	var oldest := "%s.%d.%s" % [base, max_files - 1, ext]
	if FileAccess.file_exists(oldest):
		DirAccess.remove_absolute(oldest)
	for i in range(max_files - 2, 0, -1):
		var src := "%s.%d.%s" % [base, i, ext]
		if FileAccess.file_exists(src):
			DirAccess.rename_absolute(
				src, "%s.%d.%s" % [base, i + 1, ext])
	if FileAccess.file_exists(file_path):
		DirAccess.rename_absolute(file_path, "%s.1.%s" % [base, ext])


## Fecha o sink (testes usam p/ trocar de arquivo sem vazar handle).
static func close_file() -> void:
	if _file != null:
		_file.close()
		_file = null
