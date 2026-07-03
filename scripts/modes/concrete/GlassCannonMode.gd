class_name GlassCannonMode
extends StandardMode

## Everyone starts fragile, so rounds are fast and explosive. Upgrades still
## offered between rounds.

const HP_MULTIPLIER: float = 0.4

func _init() -> void:
	mode_id = &"glass_cannon"
	display_name = "Glass Cannon"

func get_starting_hp(base_hp: float) -> float:
	return base_hp * HP_MULTIPLIER
