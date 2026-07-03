class_name GameWorld
extends Node2D

@export var round_count: int = 3

var _active_characters: Array[CharacterBase] = []
var _all_characters: Array[CharacterBase] = []
var _current_stage: StageBase
var _round_timer: float = 0.0
var _round_time_limit: float = 90.0
var _is_round_active: bool = false
var _active_mode: GameMode

@onready var _camera: Camera2D = $Camera2D
@onready var _hud: CanvasLayer = $HUD
@onready var _upgrade_screen: UpgradeScreen = $UpgradeScreen

func _ready() -> void:
	_current_stage = _find_stage()
	_collect_characters()
	_active_mode = StandardMode.new()
	GameState.phase_changed.connect(_on_phase_changed)
	GameState.set_phase(GameState.MatchPhase.ROUND_ACTIVE)
	_reset_characters()
	_start_round()

func _physics_process(delta: float) -> void:
	if not _is_round_active:
		return
	_round_timer -= delta
	if _round_timer <= 0.0 and _round_time_limit > 0.0:
		_end_round()
		return
	_update_camera()

func _collect_characters() -> void:
	for child: Node in get_children():
		if child is CharacterBase:
			var character: CharacterBase = child as CharacterBase
			_all_characters.append(character)
			var pd: GameState.PlayerData = GameState.PlayerData.new()
			pd.player_index = character.player_index
			GameState.players.append(pd)
			character.eliminated.connect(_on_character_eliminated.bind(character))

func _find_stage() -> StageBase:
	for child: Node in get_children():
		if child is StageBase:
			return child as StageBase
	return null

func _reset_characters() -> void:
	_active_characters.clear()
	for i: int in _all_characters.size():
		var character: CharacterBase = _all_characters[i]
		character.current_hp = character.stats.max_hp
		character.velocity = Vector2.ZERO
		character.jumps_remaining = character.stats.max_jumps
		character.state_machine.transition_to(&"Idle")
		character.show()
		if _current_stage != null:
			character.global_position = _current_stage.get_spawn_position(i)
		_active_characters.append(character)

func _start_round() -> void:
	GameState.current_round += 1
	_round_timer = _round_time_limit
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
	var rounds_to_win: int = ceili(round_count / 2.0) + 1
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

func _update_camera() -> void:
	if _active_characters.is_empty():
		return
	var avg: Vector2 = Vector2.ZERO
	for c: CharacterBase in _active_characters:
		avg += c.global_position
	avg /= float(_active_characters.size())
	_camera.global_position = _camera.global_position.lerp(avg, 0.05)
	if _current_stage != null:
		var bounds: Rect2 = _current_stage.camera_bounds
		_camera.global_position.x = clampf(_camera.global_position.x, bounds.position.x, bounds.end.x)
		_camera.global_position.y = clampf(_camera.global_position.y, bounds.position.y, bounds.end.y)
