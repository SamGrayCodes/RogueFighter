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

var phase: MatchPhase = MatchPhase.LOBBY
var players: Array[PlayerData] = []
var current_round: int = 0
var active_rules: GameRules
var active_mode: GameMode
var combat_resolver: CombatResolver

func _ready() -> void:
	active_rules = GameRules.new()
	active_mode = StandardMode.new()
	combat_resolver = CombatResolver.new()
	add_child(combat_resolver)

func get_mode_for_id(id: StringName) -> GameMode:
	match id:
		&"no_upgrades":
			return NoUpgradesMode.new()
		&"sudden_death":
			return SuddenDeathMode.new()
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
