class_name HaymakerEffect
extends UpgradeEffect

const KNOCKBACK_BONUS: float = 90.0
const POWER_BONUS: float = 0.12

func apply(character: CharacterBase) -> void:
	character.stats.knockback_bonus += KNOCKBACK_BONUS
	character.stats.attack_power += POWER_BONUS

func remove(character: CharacterBase) -> void:
	character.stats.knockback_bonus -= KNOCKBACK_BONUS
	character.stats.attack_power -= POWER_BONUS
