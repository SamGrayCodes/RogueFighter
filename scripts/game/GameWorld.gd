class_name GameWorld
extends Node2D

const SAM_SCENE_PATH: String = "res://scenes/characters/Sam.tscn"

var _active_characters: Array[CharacterBase] = []
var _all_characters: Array[CharacterBase] = []
var _current_stage: StageBase
var _round_timer: float = 0.0
var _is_round_active: bool = false
var _active_mode: GameMode

@onready var _camera: Camera2D = $Camera2D
@onready var _hud: CanvasLayer = $HUD
@onready var _upgrade_screen: UpgradeScreen = $UpgradeScreen
@onready var _rules_editor: RulesEditor = $RulesEditor
@onready var _players: Node2D = $Players
@onready var _spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	_current_stage = _find_stage()
	_spawner.spawn_function = _spawn_character
	if NetworkManager.is_networked():
		_setup_networked()
	else:
		_setup_local()

func _physics_process(delta: float) -> void:
	_update_camera()
	if not _is_sim_authority() or not _is_round_active:
		return
	_round_timer -= delta
	if _round_timer <= 0.0 and GameState.active_rules.round_time_limit > 0.0:
		_end_round()

# --- Setup -------------------------------------------------------------------

func _setup_local() -> void:
	_collect_characters()
	_rules_editor.rules_applied.connect(_on_rules_applied, CONNECT_ONE_SHOT)
	_rules_editor.show()

func _setup_networked() -> void:
	# Pre-placed characters exist on every peer via the scene file; the server
	# instead spawns one character per roster entry through the spawner.
	_clear_preplaced_characters()
	_rules_editor.hide()
	if not multiplayer.is_server():
		return
	# No-upgrades keeps the round loop authoritative without the (yet unbuilt)
	# networked upgrade-selection flow. See Phase 5.
	_active_mode = GameState.get_mode_for_id(&"no_upgrades")
	GameState.active_mode = _active_mode
	_spawn_networked_players()
	GameState.phase_changed.connect(_on_phase_changed)
	GameState.set_phase(GameState.MatchPhase.ROUND_ACTIVE)
	_reset_characters()
	_start_round()

func _spawn_networked_players() -> void:
	for pd: GameState.PlayerData in GameState.players:
		var character: CharacterBase = _spawner.spawn({
			"scene": SAM_SCENE_PATH,
			"index": pd.player_index,
			"peer": pd.peer_id,
		}) as CharacterBase
		_all_characters.append(character)
		character.eliminated.connect(_on_character_eliminated)

## Runs on every peer via the MultiplayerSpawner with identical spawn data.
func _spawn_character(data: Dictionary) -> Node:
	var scene: PackedScene = load(data["scene"]) as PackedScene
	var character: CharacterBase = scene.instantiate() as CharacterBase
	character.player_index = data["index"]
	character.input_authority = data["peer"]
	character.name = "Player_%d" % int(data["index"])
	return character

func _clear_preplaced_characters() -> void:
	for child: Node in _players.get_children():
		if child is CharacterBase:
			child.queue_free()

func _collect_characters() -> void:
	for child: Node in _players.get_children():
		if child is CharacterBase:
			var character: CharacterBase = child as CharacterBase
			_all_characters.append(character)
			var pd: GameState.PlayerData = GameState.PlayerData.new()
			pd.player_index = character.player_index
			GameState.players.append(pd)
			character.eliminated.connect(_on_character_eliminated)

func _find_stage() -> StageBase:
	for child: Node in get_children():
		if child is StageBase:
			return child as StageBase
	return null

# --- Round loop (server / local authority only) ------------------------------

func _reset_characters() -> void:
	_active_characters.clear()
	for i: int in _all_characters.size():
		var character: CharacterBase = _all_characters[i]
		character.current_hp = _active_mode.get_starting_hp(GameState.active_rules.starting_hp)
		character.velocity = Vector2.ZERO
		character.jumps_remaining = character.stats.max_jumps
		character.state_machine.transition_to(&"Idle")
		character.show()
		if _current_stage != null:
			character.global_position = _current_stage.get_spawn_position(i)
		_active_characters.append(character)

func _start_round() -> void:
	GameState.current_round += 1
	_round_timer = GameState.active_rules.round_time_limit
	_is_round_active = true
	_active_mode.on_round_start()
	GameState.round_started.emit(GameState.current_round)

func _end_round() -> void:
	_is_round_active = false
	var winner: int = _active_mode.get_round_winner()
	if winner >= 0:
		GameState.record_round_win(winner)
	_active_mode.on_round_end()
	GameState.round_ended.emit(winner)
	var rounds_to_win: int = ceili(GameState.active_rules.round_count / 2.0) + 1
	var match_winner: int = _active_mode.get_match_winner(rounds_to_win)
	if match_winner >= 0:
		_finish_match(match_winner)
	elif _active_mode.should_offer_upgrades():
		GameState.set_phase(GameState.MatchPhase.UPGRADE_PHASE)
	else:
		_reset_characters()
		_start_round()

func _finish_match(winner_index: int) -> void:
	GameState.set_phase(GameState.MatchPhase.RESULTS)
	GameState.match_ended.emit(winner_index)

func _on_rules_applied() -> void:
	_active_mode = GameState.active_mode
	GameState.phase_changed.connect(_on_phase_changed)
	GameState.set_phase(GameState.MatchPhase.ROUND_ACTIVE)
	_reset_characters()
	_start_round()

func _on_phase_changed(new_phase: GameState.MatchPhase) -> void:
	if new_phase == GameState.MatchPhase.UPGRADE_PHASE:
		_upgrade_screen.selections_complete.connect(_on_upgrades_complete, CONNECT_ONE_SHOT)
		_upgrade_screen.show_for_characters(_all_characters)

func _on_upgrades_complete() -> void:
	GameState.set_phase(GameState.MatchPhase.ROUND_ACTIVE)
	_reset_characters()
	_start_round()

func _on_character_eliminated(character: CharacterBase) -> void:
	if not _active_characters.has(character):
		return
	_active_characters.erase(character)
	_active_mode.on_player_eliminated(character.player_index)
	character.hide()
	var winner: int = _active_mode.get_round_winner()
	if winner >= 0:
		_end_round()

# --- Camera (runs on every peer) ---------------------------------------------

func _update_camera() -> void:
	var tracked: Array[Vector2] = []
	for child: Node in _players.get_children():
		if child is CharacterBase and (child as CanvasItem).visible:
			tracked.append((child as Node2D).global_position)
	if tracked.is_empty():
		return
	var avg: Vector2 = Vector2.ZERO
	for pos: Vector2 in tracked:
		avg += pos
	avg /= float(tracked.size())
	_camera.global_position = _camera.global_position.lerp(avg, 0.05)
	if _current_stage != null:
		var bounds: Rect2 = _current_stage.camera_bounds
		_camera.global_position.x = clampf(_camera.global_position.x, bounds.position.x, bounds.end.x)
		_camera.global_position.y = clampf(_camera.global_position.y, bounds.position.y, bounds.end.y)

func _is_sim_authority() -> bool:
	return not multiplayer.has_multiplayer_peer() or multiplayer.is_server()
