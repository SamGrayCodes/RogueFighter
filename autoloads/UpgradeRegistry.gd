extends Node

var all_upgrades: Array[UpgradeData] = []
var blacklist: Array[StringName] = []

const BLACKLIST_PATH: String = "user://blacklist.cfg"

func _ready() -> void:
	_load_blacklist()

func get_random_offers(count: int, extra_exclude: Array[StringName] = []) -> Array[UpgradeData]:
	var pool: Array[UpgradeData] = all_upgrades.filter(
		func(u: UpgradeData) -> bool:
			return not blacklist.has(u.id) and not extra_exclude.has(u.id)
	)
	pool.shuffle()
	return pool.slice(0, mini(count, pool.size()))

func set_blacklisted(id: StringName, blacklisted: bool) -> void:
	if blacklisted and not blacklist.has(id):
		blacklist.append(id)
	elif not blacklisted:
		blacklist.erase(id)
	_save_blacklist()

func _save_blacklist() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("blacklist", "ids", blacklist)
	cfg.save(BLACKLIST_PATH)

func _load_blacklist() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(BLACKLIST_PATH) != OK:
		return
	var ids: Array = cfg.get_value("blacklist", "ids", [])
	blacklist.clear()
	for id: Variant in ids:
		blacklist.append(id as StringName)
