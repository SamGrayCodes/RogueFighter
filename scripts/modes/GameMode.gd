class_name GameMode
extends RefCounted

var mode_id: StringName = &""
var display_name: String = ""

func on_match_start() -> void:
	pass

func on_round_start() -> void:
	pass

func on_player_eliminated(_player_index: int) -> void:
	pass

func get_round_winner() -> int:
	return -1

func on_round_end() -> void:
	pass

func get_match_winner(_rounds_to_win: int) -> int:
	return -1

func should_offer_upgrades() -> bool:
	return true
