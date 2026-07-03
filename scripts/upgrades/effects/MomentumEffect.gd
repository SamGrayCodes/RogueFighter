class_name MomentumEffect
extends UpgradeEffect

const SPEED_BONUS: float = 35.0
const JUMP_MULTIPLIER: float = 0.1

func apply(character: CharacterBase) -> void:
	character.stats.move_speed += SPEED_BONUS
	character.stats.jump_velocity *= (1.0 + JUMP_MULTIPLIER)

func remove(character: CharacterBase) -> void:
	character.stats.move_speed -= SPEED_BONUS
	character.stats.jump_velocity /= (1.0 + JUMP_MULTIPLIER)
