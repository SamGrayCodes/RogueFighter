class_name ProceduralAnimator
extends RefCounted

## Builds the standard procedural squash/stretch animation set (idle, run, jump,
## fall, attack, air_attack, stun, knockback) onto a character's AnimationPlayer.
## Animations drive a child node named "Visual"; per-character tint colors are
## passed in so every roster member can share the same motion language while
## keeping its own palette.

static func build_default(
	animation_player: AnimationPlayer,
	color_normal: Color,
	color_stun: Color,
	color_hit: Color
) -> void:
	if not animation_player.has_animation_library(&""):
		animation_player.add_animation_library(&"", AnimationLibrary.new())
	var lib: AnimationLibrary = animation_player.get_animation_library(&"") as AnimationLibrary
	_add_idle(lib)
	_add_run(lib)
	_add_jump(lib)
	_add_fall(lib)
	_add_attack(lib)
	_add_air_attack(lib)
	_add_stun(lib, color_stun)
	_add_knockback(lib, color_normal, color_hit)

static func _add_idle(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_LINEAR
	var t: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t, ^"Visual:position")
	anim.value_track_set_update_mode(t, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(t, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(t, 0.0, Vector2(0.0, 0.0))
	anim.track_insert_key(t, 0.5, Vector2(0.0, -3.0))
	anim.track_insert_key(t, 1.0, Vector2(0.0, 0.0))
	lib.add_animation(&"idle", anim)

static func _add_run(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.4
	anim.loop_mode = Animation.LOOP_LINEAR
	var ts: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(ts, ^"Visual:scale")
	anim.value_track_set_update_mode(ts, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(ts, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(ts, 0.0, Vector2(1.0, 1.0))
	anim.track_insert_key(ts, 0.1, Vector2(1.15, 0.88))
	anim.track_insert_key(ts, 0.2, Vector2(0.9, 1.08))
	anim.track_insert_key(ts, 0.3, Vector2(1.12, 0.9))
	anim.track_insert_key(ts, 0.4, Vector2(1.0, 1.0))
	lib.add_animation(&"run", anim)

static func _add_jump(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.25
	anim.loop_mode = Animation.LOOP_NONE
	var t: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t, ^"Visual:scale")
	anim.value_track_set_update_mode(t, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(t, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(t, 0.0, Vector2(1.2, 0.7))
	anim.track_insert_key(t, 0.12, Vector2(0.85, 1.2))
	anim.track_insert_key(t, 0.25, Vector2(0.95, 1.1))
	lib.add_animation(&"jump", anim)

static func _add_fall(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.15
	anim.loop_mode = Animation.LOOP_NONE
	var t: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t, ^"Visual:scale")
	anim.value_track_set_update_mode(t, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(t, Animation.INTERPOLATION_LINEAR)
	anim.track_insert_key(t, 0.0, Vector2(0.9, 1.1))
	anim.track_insert_key(t, 0.15, Vector2(0.88, 1.18))
	lib.add_animation(&"fall", anim)

static func _add_attack(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.35
	anim.loop_mode = Animation.LOOP_NONE
	var ts: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(ts, ^"Visual:scale")
	anim.value_track_set_update_mode(ts, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(ts, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(ts, 0.0, Vector2(0.8, 1.1))
	anim.track_insert_key(ts, 0.1, Vector2(1.3, 0.85))
	anim.track_insert_key(ts, 0.25, Vector2(1.1, 0.95))
	anim.track_insert_key(ts, 0.35, Vector2(1.0, 1.0))
	var tp: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tp, ^"Visual:position")
	anim.value_track_set_update_mode(tp, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(tp, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(tp, 0.0, Vector2(0.0, 0.0))
	anim.track_insert_key(tp, 0.1, Vector2(14.0, 0.0))
	anim.track_insert_key(tp, 0.35, Vector2(0.0, 0.0))
	lib.add_animation(&"attack", anim)

static func _add_air_attack(lib: AnimationLibrary) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.3
	anim.loop_mode = Animation.LOOP_NONE
	var ts: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(ts, ^"Visual:scale")
	anim.value_track_set_update_mode(ts, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(ts, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(ts, 0.0, Vector2(1.1, 0.8))
	anim.track_insert_key(ts, 0.1, Vector2(0.85, 1.3))
	anim.track_insert_key(ts, 0.3, Vector2(1.0, 1.0))
	var tp: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tp, ^"Visual:position")
	anim.value_track_set_update_mode(tp, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(tp, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(tp, 0.0, Vector2(0.0, 0.0))
	anim.track_insert_key(tp, 0.1, Vector2(0.0, 16.0))
	anim.track_insert_key(tp, 0.3, Vector2(0.0, 0.0))
	lib.add_animation(&"air_attack", anim)

static func _add_stun(lib: AnimationLibrary, color_stun: Color) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.3
	anim.loop_mode = Animation.LOOP_LINEAR
	var tc: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tc, ^"Visual:modulate")
	anim.value_track_set_update_mode(tc, Animation.UPDATE_CONTINUOUS)
	anim.track_insert_key(tc, 0.0, color_stun)
	anim.track_insert_key(tc, 0.15, Color(color_stun.r, color_stun.g, color_stun.b, 0.5))
	anim.track_insert_key(tc, 0.3, color_stun)
	var tp: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tp, ^"Visual:position")
	anim.value_track_set_update_mode(tp, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(tp, Animation.INTERPOLATION_LINEAR)
	anim.track_insert_key(tp, 0.0, Vector2(-4.0, 0.0))
	anim.track_insert_key(tp, 0.075, Vector2(4.0, 0.0))
	anim.track_insert_key(tp, 0.15, Vector2(-3.0, 0.0))
	anim.track_insert_key(tp, 0.225, Vector2(3.0, 0.0))
	anim.track_insert_key(tp, 0.3, Vector2(-4.0, 0.0))
	lib.add_animation(&"stun", anim)

static func _add_knockback(lib: AnimationLibrary, color_normal: Color, color_hit: Color) -> void:
	var anim: Animation = Animation.new()
	anim.length = 0.2
	anim.loop_mode = Animation.LOOP_NONE
	var tc: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tc, ^"Visual:modulate")
	anim.value_track_set_update_mode(tc, Animation.UPDATE_CONTINUOUS)
	anim.track_insert_key(tc, 0.0, color_hit)
	anim.track_insert_key(tc, 0.2, color_normal)
	var ts: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(ts, ^"Visual:scale")
	anim.value_track_set_update_mode(ts, Animation.UPDATE_CONTINUOUS)
	anim.track_set_interpolation_type(ts, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(ts, 0.0, Vector2(0.75, 1.3))
	anim.track_insert_key(ts, 0.2, Vector2(1.0, 1.0))
	lib.add_animation(&"knockback", anim)
