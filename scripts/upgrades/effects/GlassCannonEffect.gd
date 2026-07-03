class_name GlassCannonEffect
extends UpgradeEffect

const POWER_BONUS: float = 0.4
const WEIGHT_PENALTY: float = 0.25

func apply(character: CharacterBase) -> void:
	character.stats.attack_power += POWER_BONUS
	character.stats.weight -= WEIGHT_PENALTY

func remove(character: CharacterBase) -> void:
	character.stats.attack_power -= POWER_BONUS
	character.stats.weight += WEIGHT_PENALTY
