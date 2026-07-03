class_name NoUpgradesMode
extends StandardMode

func _init() -> void:
	mode_id = &"no_upgrades"
	display_name = "No Upgrades"

func should_offer_upgrades() -> bool:
	return false
