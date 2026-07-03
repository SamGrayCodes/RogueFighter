class_name HurtboxComponent
extends Area2D

signal hit_received(attack_data: AttackData, attacker: CharacterBase)

var invincible: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if invincible:
		return
	if area is HitboxComponent and area.attack_data != null:
		var hitbox: HitboxComponent = area as HitboxComponent
		var attacker: CharacterBase = hitbox.get_parent() as CharacterBase
		if attacker == get_parent():
			return
		hit_received.emit(hitbox.attack_data, attacker)
