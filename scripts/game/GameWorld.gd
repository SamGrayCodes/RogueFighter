class_name GameWorld
extends Node2D

@export var round_count: int = 3

var _active_characters: Array[CharacterBase] = []
var _current_stage: StageBase
var _round_timer: float = 0.0
var _round_time_limit: float = 90.0
var _is_round_active: bool = false
var _active_mode: GameMode

@onready var _camera: Camera2D = $Camera2D
@onready var _hud: CanvasLayer = $HUD

func _ready() -> void:
	_active_mode = StandardMode.new()
	GameState.set_phase(GameState.MatchPhase.ROUND_ACTIVE)
	_start_round()

func _physics_process(delta: float) -> void:
	if not _is_round_active:
		return
	_round_timer -= delta
	if _round_timer <= 0.0 and _round_time_limit > 0.0:
		_end_round()
		return
	_update_camera()

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
	var match_winner: int = _active_mode.get_match_winner(ceili(round_count / 2.0) + 1)
	if match_winner >= 0:
		_finish_match(match_winner)
	elif _active_mode.should_offer_upgrades():
		GameState.set_phase(GameState.MatchPhase.UPGRADE_PHASE)
	else:
		_start_round()

func _finish_match(winner_index: int) -> void:
	GameState.set_phase(GameState.MatchPhase.RESULTS)
	GameState.match_ended.emit(winner_index)

func register_character(character: CharacterBase) -> void:
	_active_characters.append(character)
	character.eliminated.connect(_on_character_eliminated.bind(character))

func _on_character_eliminated(character: CharacterBase) -> void:
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
	if _current_stage:
		var bounds: Rect2 = _current_stage.camera_bounds
		_camera.global_position.x = clampf(_camera.global_position.x, bounds.position.x, bounds.end.x)
		_camera.global_position.y = clampf(_camera.global_position.y, bounds.position.y, bounds.end.y)
