## Runtime debug console (F1): generic shell + game commands.
## Toggle by PHYSICAL key (zero InputMap; ABNT2-safe: F1, never `~`).
## Two states: COLLAPSED (bar only, game running) and EXPANDED
## (log visible, tree paused, focus on input). F1 or click expands;
## Enter runs and schedules collapse after collapse_delay (new key or
## hover cancels); Esc/F1 collapses at once. `/` prefix optional.
## Output reads Log.recent() — no output system of its own.
## Commands talk to the game via groups + find_child duck-typing
## (zero coupling). Debug-only; outside debug builds the node
## frees itself in _ready.
## v1: help/hp/damage/heal/pos/score/spawn/tags, default target = player.
## spawn [n]: instantiates Asteroid.tscn in a ring around the player.
extends CanvasLayer


## Physical key that toggles the console. F1, never a mapped action.
const TOGGLE_KEY := KEY_F1
## Max log lines shown in the output panel.
const MAX_OUT := 15
## Asteroid scene spawned by the spawn command (debug-only coupling).
const ASTEROID := preload("res://Source/Prefabs/Asteroids/Asteroid.tscn")
## Spawn ring radius around the player.
const SPAWN_RING_R := 300.0

## Seconds until collapse after Enter (tests lower it to go faster).
var collapse_delay := 3.0

var _commands: Dictionary = {}
var _open := false
var _hovering := false
var _collapse_gen := 0
var _last_result := ""

@onready var _panel: PanelContainer = $Panel
@onready var _out: RichTextLabel = $Panel/Margin/Box/Out
@onready var _line: LineEdit = $Panel/Margin/Box/Line


func _ready() -> void:
	if not OS.has_feature("debug"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = GameConfig.UI_DEBUG
	_register_commands()
	_collapse(true)


## Toggles between expanded and collapsed states.
func toggle() -> void:
	if _open:
		_collapse()
	else:
		_expand()


## @return true while the console is expanded
func is_open() -> bool:
	return _open


## Expands the console: pauses the tree and focuses the input line.
func _expand() -> void:
	if _open:
		return
	_open = true
	get_tree().paused = _open
	_panel.custom_minimum_size = Vector2(0, 220)
	_panel.offset_top = -220
	_out.visible = true
	_refresh()
	_line.clear()
	_line.grab_focus()


## Collapses the console back to its bar and unpauses the tree.
## @param silent Skip focus release (used during _ready)
func _collapse(silent := false) -> void:
	_collapse_gen += 1
	_open = false
	get_tree().paused = false
	# Auto-fit: zeroed offsets, the container shrinks to the content
	# minimum (Line + margins) and grows upward (grow in the .tscn).
	_panel.custom_minimum_size = Vector2(0, 0)
	_panel.offset_top = 0
	_out.visible = false
	if not silent and is_inside_tree():
		get_viewport().gui_release_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.physical_keycode == TOGGLE_KEY:
		toggle()
		get_viewport().set_input_as_handled()
	elif _open and key.physical_keycode == KEY_ESCAPE:
		_collapse()
		get_viewport().set_input_as_handled()


## Runs one line and returns the result (testable without UI).
## `/` (or `\`) prefix is optional: `/damage 30` == `damage 30`.
## @param text Raw command line
## @return Command output, "" when there is nothing to show
func run(text: String) -> String:
	var t := text.strip_edges()
	while t.begins_with("/") or t.begins_with("\\"):
		t = t.substr(1).strip_edges()
	var parts := t.split(" ", false)
	if parts.is_empty():
		return ""
	var cmd := StringName(parts[0].to_lower())
	if not _commands.has(cmd):
		return "desconhecido: %s (help lista)" % parts[0]
	var args: Array[String] = []
	for i in range(1, parts.size()):
		args.append(parts[i])
	return String(_commands[cmd]["call"].call(args))


## Registers (or overrides) one console command.
## @param cmd Command name (lowercase, no prefix)
## @param help One-line help shown by the help command
## @param fn Callable receiving Array[String] and returning String
func register_command(cmd: StringName, help: String, fn: Callable) -> void:
	_commands[cmd] = {"help": help, "call": fn}


func _on_submit(text: String) -> void:
	if not _open:
		_expand()
	var echo := text.strip_edges()
	if echo != "":
		Log.info(&"console", "> " + echo)
		_last_result = run(echo)
		if _last_result != "":
			Log.info(&"console", _last_result)
	_line.clear()
	_line.select_all()
	_line.grab_focus()
	_refresh()
	_schedule_collapse() # Enter schedules collapse; typing/hover cancels.


## Leaving the hover reschedules collapse (the previous timer was
## consumed holding it open — without this, it never collapses alone).
func _on_hover_out() -> void:
	_hovering = false
	if _open:
		_schedule_collapse()


## Collapses after collapse_delay, unless a new generation or hover wins.
func _schedule_collapse() -> void:
	_collapse_gen += 1
	var gen := _collapse_gen
	await get_tree().create_timer(collapse_delay).timeout
	if gen == _collapse_gen and _open and not _hovering:
		_collapse()


## Renders the last MAX_OUT log entries into the output panel.
func _refresh() -> void:
	var lines: PackedStringArray = []
	for e in Log.recent(MAX_OUT):
		lines.append("[%s][%s][%s] %s" % [e["t"], e["lvl"], e["cat"], e["msg"]])
	_out.text = "\n".join(lines)


func _on_panel_mouse_entered() -> void:
	_hovering = true


func _on_line_focus_entered() -> void:
	if not _open:
		_expand()


## Registers the v1 game commands (see each _cmd_* for the contract).
func _register_commands() -> void:
	register_command(&"help", "lista comandos",
		func(_args: Array) -> String: return _cmd_help())
	register_command(&"hp", "hp [alvo] — mostra casco atual/max",
		func(args: Array) -> String: return _cmd_hp(args))
	register_command(&"damage", "damage [alvo] <n> — dano (passa pela defesa)",
		func(args: Array) -> String: return _cmd_damage(args))
	register_command(&"heal", "heal [alvo] [n] — cura (vazio = total)",
		func(args: Array) -> String: return _cmd_heal(args))
	register_command(&"pos", "pos [alvo] — posicao global",
		func(args: Array) -> String: return _cmd_pos(args))
	register_command(&"score", "score <n> — soma pontos ao placar",
		func(args: Array) -> String: return _cmd_score(args))
	register_command(&"spawn", "spawn [n] — asteroides em anel ao redor do player",
		func(args: Array) -> String: return _cmd_spawn(args))
	register_command(&"tags", "tags — liga/desliga os nametags de debug",
		func(_args: Array) -> String: return _cmd_tags())


## Target: "" or "me" = player ship; "asteroid" = first asteroid;
## otherwise a node name inside the ship/asteroid groups.
## @param token Raw target token from the command line
## @return Target root, null when nothing matches
func _resolve_target(token: String) -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	if token == "" or token == "me":
		return tree.get_first_node_in_group(GameConfig.PLAYER_SHIP)
	if token == "asteroid":
		return tree.get_first_node_in_group(GameConfig.ASTEROIDS)
	for group in [GameConfig.PLAYER_SHIP, GameConfig.ASTEROIDS]:
		for n in tree.get_nodes_in_group(group):
			if String(n.name).to_lower() == token.to_lower():
				return n
	return null


## Finds the HurtArea2D under a target root (cross-scene safe:
## % unique names do not resolve from outside the target scene).
## @param target Target root (player or asteroid)
## @return The hurt area, null when absent
func _hurt_of(target: Node) -> HurtArea2D:
	if target == null:
		return null
	return target.find_child("HurtArea2D", true, false) as HurtArea2D


## Finds the GameResource (hull) under a target root.
## @param target Target root (player or asteroid)
## @return The health resource, null when absent
func _health_of(target: Node) -> GameResource:
	if target == null:
		return null
	return target.find_child("HealthResource", true, false) as GameResource


## Lists every registered command with its one-line help.
## @return Sorted help lines
func _cmd_help() -> String:
	var names: Array = _commands.keys()
	names.sort()
	var lines: PackedStringArray = []
	for n in names:
		lines.append("%s — %s" % [n, _commands[n]["help"]])
	return "\n".join(lines)


## Shows current/max hull of the target.
## @param args Optional target token
## @return "cur/max", "sem alvo" or "sem Health em X"
func _cmd_hp(args: Array) -> String:
	var target := _resolve_target(String(args[0]) if not args.is_empty() else "")
	if target == null:
		return "sem alvo"
	var h := _health_of(target)
	if h == null:
		return "sem Health em %s" % target.name
	return "%d/%d" % [h.current_amount, h.max_amount]


## damage [alvo] <n>: a single number hits the default target.
## Goes through HurtArea2D.hurt() so defense applies; falls back to
## HealthResource.decrease() when no hurt area is found. Bypasses the
## friendly-fire check by design (debug tool, explicit intent).
## @param args Optional target token + damage amount
## @return Result line or usage
func _cmd_damage(args: Array) -> String:
	var token := ""
	var num := ""
	if args.size() == 1:
		num = String(args[0])
	elif args.size() >= 2:
		token = String(args[0])
		num = String(args[1])
	if not num.is_valid_int():
		return "uso: damage [alvo] <n>"
	var target := _resolve_target(token)
	if target == null:
		return "sem alvo"
	var hurt := _hurt_of(target)
	if hurt != null:
		var hit := HitData.new()
		hit.damage = int(num)
		hurt.hurt(hit)
		return "dano %d em %s" % [int(num), target.name]
	var h := _health_of(target)
	if h == null:
		return "sem Health em %s" % target.name
	h.decrease(int(num))
	return "dano %d em %s" % [int(num), target.name]


## heal [alvo] [n]: a single number heals the default target.
## Empty amount replenishes to full.
## @param args Optional target token + heal amount
## @return Result line or usage
func _cmd_heal(args: Array) -> String:
	var token := ""
	var num := ""
	if args.size() == 1:
		if String(args[0]).is_valid_int():
			num = String(args[0])
		else:
			token = String(args[0])
	elif args.size() >= 2:
		token = String(args[0])
		num = String(args[1])
		if not num.is_valid_int():
			return "uso: heal [alvo] [n]"
	var target := _resolve_target(token)
	if target == null:
		return "sem alvo"
	var h := _health_of(target)
	if h == null:
		return "sem Health em %s" % target.name
	if num == "":
		h.replenish()
	else:
		h.increase(int(num))
	return "cura em %s" % target.name


## Shows the global position of the target.
## @param args Optional target token
## @return "Name em (x, y)" or "sem alvo"
func _cmd_pos(args: Array) -> String:
	var target := _resolve_target(String(args[0]) if not args.is_empty() else "")
	if target == null or not (target is Node2D):
		return "sem alvo"
	var b := target as Node2D
	return "%s em (%.0f, %.0f)" % [target.name, b.global_position.x, b.global_position.y]


## Adds raw points to the ScoreSingleton (spending stays on decrease).
## @param args Point amount
## @return Result line or usage
func _cmd_score(args: Array) -> String:
	if args.is_empty() or not String(args[0]).is_valid_int():
		return "uso: score <n>"
	ScoreSingleton.increase(int(args[0]))
	return "placar +%d" % int(args[0])


## Spawns n asteroids in a ring around the player at SPAWN_RING_R.
## Parent is the current scene (documented level fallback, same as
## Spawner2D._resolve_container priority 3); global_position is set
## AFTER add_child so no parent transform leaks in.
## @param args Optional spawn count (default 1)
## @return Result line
func _cmd_spawn(args: Array) -> String:
	var n := 1
	if not args.is_empty():
		if not String(args[0]).is_valid_int():
			return "uso: spawn [n]"
		n = maxi(1, int(args[0]))
	var me := _resolve_target("") as Node2D
	if me == null:
		return "sem player"
	var scene := get_tree().current_scene
	if scene == null:
		return "sem cena atual"
	for i in n:
		var ang := TAU * float(i) / float(maxi(1, n))
		var rock := ASTEROID.instantiate() as Node2D
		scene.add_child(rock)
		rock.global_position = me.global_position \
			+ Vector2(cos(ang), sin(ang)) * SPAWN_RING_R
	return "spawnados %d" % n


## Toggles the debug nametags through the DebugNametag bulk statics.
## @return New visibility state
func _cmd_tags() -> String:
	DebugNametag.toggle(get_tree())
	return "tags visiveis" if DebugNametag.is_showing() else "tags ocultas"
