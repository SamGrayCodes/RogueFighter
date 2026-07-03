class_name AdrenalineEffect
extends UpgradeEffect

const SPEED_BONUS: float = 25.0
const POWER_BONUS: float = 0.1

func apply(character: CharacterBase) -> void:
	character.stats.move_speed += SPEED_BONUS
	character.stats.attack_power += POWER_BONUS

func remove(character: CharacterBase) -> void:
	character.stats.move_speed -= SPEED_BONUS
	character.stats.attack_power -= POWER_BONUS
