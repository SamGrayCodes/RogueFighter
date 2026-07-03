class_name BulwarkEffect
extends UpgradeEffect

const WEIGHT_BONUS: float = 0.35
const SPEED_PENALTY: float = 35.0

func apply(character: CharacterBase) -> void:
	character.stats.weight += WEIGHT_BONUS
	character.stats.move_speed -= SPEED_PENALTY

func remove(character: CharacterBase) -> void:
	character.stats.weight -= WEIGHT_BONUS
	character.stats.move_speed += SPEED_PENALTY
