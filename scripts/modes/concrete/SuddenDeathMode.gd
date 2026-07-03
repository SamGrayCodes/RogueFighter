class_name SuddenDeathMode
extends StandardMode

func _init() -> void:
	mode_id = &"sudden_death"
	display_name = "Sudden Death"

func get_starting_hp(_base_hp: float) -> float:
	return 1.0

func should_offer_upgrades() -> bool:
	return false
