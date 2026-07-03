class_name HeavyweightEffect
extends UpgradeEffect

const BONUS: float = 0.3

func apply(character: CharacterBase) -> void:
	character.stats.weight += BONUS

func remove(character: CharacterBase) -> void:
	character.stats.weight -= BONUS
