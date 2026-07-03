class_name IronSkinEffect
extends UpgradeEffect

const HP_BONUS: float = 30.0

func apply(character: CharacterBase) -> void:
	character.stats.max_hp += HP_BONUS
	character.current_hp = minf(character.current_hp + HP_BONUS, character.stats.max_hp)

func remove(character: CharacterBase) -> void:
	character.stats.max_hp -= HP_BONUS
	character.current_hp = minf(character.current_hp, character.stats.max_hp)
