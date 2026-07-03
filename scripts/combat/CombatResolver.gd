class_name CombatResolver
extends Node

const BASE_GRAVITY: float = 980.0
const RAGE_SCALE: float = 0.5

func resolve_hit(target: CharacterBase, attack_data: AttackData, attacker: CharacterBase) -> void:
	if not multiplayer.is_server():
		return

	var rage_bonus: float = 1.0 + (1.0 - (target.current_hp / target.stats.max_hp)) * RAGE_SCALE
	var scaled_damage: float = attack_data.damage * attacker.stats.attack_power
	target.current_hp -= scaled_damage
	target.current_hp = maxf(target.current_hp, 0.0)

	var facing: float = sign(target.global_position.x - attacker.global_position.x)
	if facing == 0.0:
		facing = 1.0
	var angle_rad: float = deg_to_rad(attack_data.knockback_angle)
	var kb_power: float = attack_data.knockback_power * rage_bonus / target.stats.weight
	target.velocity = Vector2(
		cos(angle_rad) * kb_power * facing,
		sin(angle_rad) * kb_power
	)

	var stun_state: StunState = target.state_machine._states.get(&"Stun") as StunState
	if stun_state:
		stun_state.set_duration(attack_data.hitstun_duration)
	target.state_machine.transition_to(&"Knockback")

	target.hurtbox.invincible = true
	var timer: SceneTreeTimer = get_tree().create_timer(attack_data.hitstun_duration)
	timer.timeout.connect(func() -> void: target.hurtbox.invincible = false)
