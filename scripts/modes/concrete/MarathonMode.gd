class_name MarathonMode
extends StandardMode

## Doubled starting HP for long, grinding rounds. Upgrades still offered.

const HP_MULTIPLIER: float = 2.0

func _init() -> void:
	mode_id = &"marathon"
	display_name = "Marathon"

func get_starting_hp(base_hp: float) -> float:
	return base_hp * HP_MULTIPLIER
