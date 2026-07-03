class_name HighJumpEffect
extends UpgradeEffect

const MULTIPLIER: float = 0.12

func apply(character: CharacterBase) -> void:
	character.stats.jump_velocity *= (1.0 + MULTIPLIER)

func remove(character: CharacterBase) -> void:
	character.stats.jump_velocity /= (1.0 + MULTIPLIER)
