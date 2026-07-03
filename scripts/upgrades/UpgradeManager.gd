class_name UpgradeManager
extends Node

var applied_upgrades: Array[UpgradeData] = []
var _active_effects: Array[UpgradeEffect] = []

func add_upgrade(data: UpgradeData) -> void:
	if data.effect_script == null:
		return
	var effect: UpgradeEffect = data.effect_script.new() as UpgradeEffect
	effect.apply(get_parent() as CharacterBase)
	applied_upgrades.append(data)
	_active_effects.append(effect)

func remove_all() -> void:
	var character: CharacterBase = get_parent() as CharacterBase
	for effect: UpgradeEffect in _active_effects:
		effect.remove(character)
	applied_upgrades.clear()
	_active_effects.clear()
