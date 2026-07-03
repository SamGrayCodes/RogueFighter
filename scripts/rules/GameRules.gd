class_name GameRules
extends Resource

@export var round_count: int = 3
@export var round_time_limit: float = 90.0
@export var starting_hp: float = 100.0
@export var damage_scaling: float = 1.0
@export var upgrade_offers_per_round: int = 3
@export var starting_upgrades: Array[StringName] = []
@export var blacklisted_upgrades: Array[StringName] = []
@export var allowed_stages: Array[StringName] = []
@export var allowed_characters: Array[StringName] = []
@export var game_mode_id: StringName = &"standard"
