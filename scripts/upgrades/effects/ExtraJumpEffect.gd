class_name ExtraJumpEffect
extends UpgradeEffect

func apply(character: CharacterBase) -> void:
	character.stats.max_jumps += 1

func remove(character: CharacterBase) -> void:
	character.stats.max_jumps = maxi(1, character.stats.max_jumps - 1)
