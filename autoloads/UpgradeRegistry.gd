extends Node

const UPGRADES_DIR: String = "res://resources/upgrades/"
const BLACKLIST_PATH: String = "user://blacklist.cfg"

var all_upgrades: Array[UpgradeData] = []
var blacklist: Array[StringName] = []

func _ready() -> void:
	_load_upgrades()
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

func _load_upgrades() -> void:
	var dir: DirAccess = DirAccess.open(UPGRADES_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var upgrade: UpgradeData = ResourceLoader.load(UPGRADES_DIR + file_name) as UpgradeData
			if upgrade != null:
				all_upgrades.append(upgrade)
		file_name = dir.get_next()

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
