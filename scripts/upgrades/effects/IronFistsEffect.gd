class_name IronFistsEffect
extends UpgradeEffect

const BONUS: float = 70.0

func apply(character: CharacterBase) -> void:
	character.stats.knockback_bonus += BONUS

func remove(character: CharacterBase) -> void:
	character.stats.knockback_bonus -= BONUS
