class_name SecondWindEffect
extends UpgradeEffect

const HEAL_PERCENT: float = 0.4

func apply(character: CharacterBase) -> void:
	var heal: float = character.stats.max_hp * HEAL_PERCENT
	character.current_hp = minf(character.current_hp + heal, character.stats.max_hp)

func remove(_character: CharacterBase) -> void:
	pass
