class_name LightfootEffect
extends UpgradeEffect

const SPEED_BONUS: float = 30.0
const GRAVITY_REDUCTION: float = 0.15

func apply(character: CharacterBase) -> void:
	character.stats.move_speed += SPEED_BONUS
	character.stats.gravity_scale -= GRAVITY_REDUCTION

func remove(character: CharacterBase) -> void:
	character.stats.move_speed -= SPEED_BONUS
	character.stats.gravity_scale += GRAVITY_REDUCTION
