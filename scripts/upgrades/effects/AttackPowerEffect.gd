class_name AttackPowerEffect
extends UpgradeEffect

const BONUS: float = 0.2

func apply(character: CharacterBase) -> void:
	character.stats.attack_power += BONUS

func remove(character: CharacterBase) -> void:
	character.stats.attack_power -= BONUS
