class_name KnockbackState
extends CharacterState

const DRAG: float = 0.85

## Facing to restore when the knockback ends: whatever direction the character faced before
## being hit. Overridden by live move input on recovery.
var _restore_facing: float = 1.0

func enter() -> void:
	character.play_animation(&"knockback")
	character.flash_hit()
	_restore_facing = character.get_facing()
	# Face away from where the hit came from — i.e. the direction of the knockback push.
	# velocity is set before this transition in CombatResolver.resolve_hit.
	if character.velocity.x != 0.0:
		character.set_facing(sign(character.velocity.x))

func physics_update(_delta: float) -> void:
	character.velocity.x *= DRAG
	# Recover only once the body has settled AND the knockback (death) animation has played
	# through. Non-looping clips report is_action_playing() == false when finished; the
	# procedural knockback anim (LOOP_NONE, 0.2s) self-terminates too, so this is safe for
	# both render paths.
	if character.is_on_floor() and abs(character.velocity.x) < 20.0 and not character.is_action_playing():
		character.jumps_remaining = character.stats.max_jumps
		machine.transition_to(&"Idle")

func exit() -> void:
	# Recover facing: turn toward the direction being pressed, else back to the pre-hit facing.
	var move_dir: float = character.get_move_input()
	if move_dir != 0.0:
		character.set_facing(move_dir)
	else:
		character.set_facing(_restore_facing)
