class_name SpeedBoostEffect
extends UpgradeEffect

const BONUS: float = 45.0

func apply(character: CharacterBase) -> void:
	character.stats.move_speed += BONUS

func remove(character: CharacterBase) -> void:
	character.stats.move_speed -= BONUS
