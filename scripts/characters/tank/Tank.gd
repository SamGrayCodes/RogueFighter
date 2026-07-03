class_name Tank
extends CharacterBase

const COLOR_NORMAL: Color = Color(0.85, 0.4, 0.16, 1.0)
const COLOR_STUN: Color = Color(0.95, 0.85, 0.1, 1.0)
const COLOR_HIT: Color = Color(1.0, 0.25, 0.2, 1.0)

func _ready() -> void:
	super._ready()
	ProceduralAnimator.build_default(animation_player, COLOR_NORMAL, COLOR_STUN, COLOR_HIT)
