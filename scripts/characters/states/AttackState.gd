class_name AttackState
extends CharacterState

var _elapsed_frames: int = 0
var _attack_data: AttackData

func enter() -> void:
	_elapsed_frames = 0
	_attack_data = character.get_current_attack_data()
	character.play_animation(&"attack")

func exit() -> void:
	character.hitbox.deactivate()

func physics_update(_delta: float) -> void:
	_elapsed_frames += 1
	if _elapsed_frames >= _attack_data.active_frames.x and _elapsed_frames <= _attack_data.active_frames.y:
		character.hitbox.activate(_attack_data)
	else:
		character.hitbox.deactivate()
	var anim_done: bool = not character.is_action_playing()
	if anim_done:
		machine.transition_to(&"Idle")
