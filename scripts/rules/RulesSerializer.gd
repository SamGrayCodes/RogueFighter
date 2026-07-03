class_name RulesSerializer
extends RefCounted

const RULES_DIR: String = "user://rules/"

static func save(rules: GameRules, slot_name: String) -> Error:
	if not DirAccess.dir_exists_absolute(RULES_DIR):
		DirAccess.make_dir_absolute(RULES_DIR)
	return ResourceSaver.save(rules, RULES_DIR + slot_name + ".tres")

static func load_slot(slot_name: String) -> GameRules:
	var path: String = RULES_DIR + slot_name + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as GameRules

static func list_saved() -> Array[String]:
	var result: Array[String] = []
	var dir: DirAccess = DirAccess.open(RULES_DIR)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			result.append(file_name.trim_suffix(".tres"))
		file_name = dir.get_next()
	return result
