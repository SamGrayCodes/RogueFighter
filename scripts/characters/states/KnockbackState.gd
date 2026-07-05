class_name KnockbackState
extends CharacterState

const DRAG: float = 0.85

func enter() -> void:
	character.play_animation(&"knockback")
	character.flash_hit()

func physics_update(_delta: float) -> void:
	character.velocity.x *= DRAG
	# Recover only once the body has settled AND the knockback (death) animation has played
	# through. Non-looping clips report is_action_playing() == false when finished; the
	# procedural knockback anim (LOOP_NONE, 0.2s) self-terminates too, so this is safe for
	# both render paths.
	if character.is_on_floor() and abs(character.velocity.x) < 20.0 and not character.is_action_playing():
		character.jumps_remaining = character.stats.max_jumps
		machine.transition_to(&"Idle")
