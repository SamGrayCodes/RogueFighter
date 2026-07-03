class_name Flash
extends CharacterBase

const COLOR_NORMAL: Color = Color(0.2, 0.85, 0.55, 1.0)
const COLOR_STUN: Color = Color(0.95, 0.85, 0.1, 1.0)
const COLOR_HIT: Color = Color(1.0, 0.3, 0.4, 1.0)

func _ready() -> void:
	super._ready()
	ProceduralAnimator.build_default(animation_player, COLOR_NORMAL, COLOR_STUN, COLOR_HIT)
