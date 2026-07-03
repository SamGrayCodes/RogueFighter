class_name StandardMode
extends GameMode

var _eliminated: Array[int] = []

func _init() -> void:
	mode_id = &"standard"
	display_name = "Standard"

func on_round_start() -> void:
	_eliminated.clear()

func on_player_eliminated(player_index: int) -> void:
	if not _eliminated.has(player_index):
		_eliminated.append(player_index)

func get_round_winner() -> int:
	var living: Array[int] = []
	for pd: GameState.PlayerData in GameState.players:
		if not _eliminated.has(pd.player_index):
			living.append(pd.player_index)
	if living.size() == 1:
		return living[0]
	return -1

func get_match_winner(rounds_to_win: int) -> int:
	return GameState.get_match_winner(rounds_to_win)
