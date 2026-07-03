extends Node

signal phase_changed(new_phase: MatchPhase)
signal round_started(round_number: int)
signal round_ended(winner_index: int)
signal match_ended(winner_index: int)

enum MatchPhase {
	LOBBY,
	CHARACTER_SELECT,
	STAGE_SELECT,
	ROUND_ACTIVE,
	UPGRADE_PHASE,
	RESULTS,
}

class PlayerData:
	var player_index: int = 0
	var character_id: StringName = &""
	var round_wins: int = 0
	var is_local: bool = true
	var peer_id: int = 1

## One selectable piece of content (a character or a stage) exposed to the
## select screens and resolved to a scene at spawn time.
class ContentEntry:
	var id: StringName = &""
	var display_name: String = ""
	var scene_path: String = ""

var phase: MatchPhase = MatchPhase.LOBBY
var players: Array[PlayerData] = []
var current_round: int = 0
var active_rules: GameRules
var active_mode: GameMode
var combat_resolver: CombatResolver

var character_catalog: Array[ContentEntry] = []
var stage_catalog: Array[ContentEntry] = []
var selected_stage_id: StringName = &""
var last_match_winner: int = -1

func _ready() -> void:
	active_rules = GameRules.new()
	active_mode = StandardMode.new()
	combat_resolver = CombatResolver.new()
	add_child(combat_resolver)
	_build_catalogs()

func _build_catalogs() -> void:
	character_catalog = [
		_make_entry(&"sam", "Sam", "res://scenes/characters/Sam.tscn"),
		_make_entry(&"tank", "Tank", "res://scenes/characters/Tank.tscn"),
		_make_entry(&"flash", "Flash", "res://scenes/characters/Flash.tscn"),
	]
	stage_catalog = [
		_make_entry(&"stage_01", "Platform Zero", "res://scenes/stages/Stage01.tscn"),
		_make_entry(&"stage_02", "Skyline", "res://scenes/stages/Stage02.tscn"),
		_make_entry(&"stage_03", "Twin Pillars", "res://scenes/stages/Stage03.tscn"),
	]
	selected_stage_id = stage_catalog[0].id

func _make_entry(id: StringName, display_name: String, scene_path: String) -> ContentEntry:
	var entry: ContentEntry = ContentEntry.new()
	entry.id = id
	entry.display_name = display_name
	entry.scene_path = scene_path
	return entry

func get_character_scene(id: StringName) -> String:
	for entry: ContentEntry in character_catalog:
		if entry.id == id:
			return entry.scene_path
	if not character_catalog.is_empty():
		return character_catalog[0].scene_path
	return ""

func get_stage_scene(id: StringName) -> String:
	for entry: ContentEntry in stage_catalog:
		if entry.id == id:
			return entry.scene_path
	if not stage_catalog.is_empty():
		return stage_catalog[0].scene_path
	return ""

func get_character_name(id: StringName) -> String:
	for entry: ContentEntry in character_catalog:
		if entry.id == id:
			return entry.display_name
	return String(id)

func get_character_index(id: StringName) -> int:
	for i: int in character_catalog.size():
		if character_catalog[i].id == id:
			return i
	return 0

func get_stage_index(id: StringName) -> int:
	for i: int in stage_catalog.size():
		if stage_catalog[i].id == id:
			return i
	return 0

func get_mode_for_id(id: StringName) -> GameMode:
	match id:
		&"no_upgrades":
			return NoUpgradesMode.new()
		&"sudden_death":
			return SuddenDeathMode.new()
		&"glass_cannon":
			return GlassCannonMode.new()
		&"marathon":
			return MarathonMode.new()
		_:
			return StandardMode.new()

func set_phase(new_phase: MatchPhase) -> void:
	phase = new_phase
	phase_changed.emit(new_phase)

func add_player(index: int, character_id: StringName, is_local: bool = true, peer_id: int = 1) -> void:
	var pd: PlayerData = PlayerData.new()
	pd.player_index = index
	pd.character_id = character_id
	pd.is_local = is_local
	pd.peer_id = peer_id
	players.append(pd)

func clear_players() -> void:
	players.clear()

func record_round_win(player_index: int) -> void:
	for pd: PlayerData in players:
		if pd.player_index == player_index:
			pd.round_wins += 1
			return

func get_match_winner(rounds_to_win: int) -> int:
	for pd: PlayerData in players:
		if pd.round_wins >= rounds_to_win:
			return pd.player_index
	return -1
