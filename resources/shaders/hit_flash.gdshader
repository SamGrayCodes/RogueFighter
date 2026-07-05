shader_type canvas_item;

// Briefly tints a sprite toward a solid color when hit. Drive `flash_amount` from
// 0.0 (normal) to 1.0 (full flash) and fade it back for a one-shot hit flash.
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Tint RGB toward flash_color, but preserve the sprite's own alpha so transparent
	// pixels stay transparent (no colored rectangle around the sprite).
	vec3 tinted = mix(tex.rgb, flash_color.rgb, flash_amount * flash_color.a);
	COLOR = vec4(tinted, tex.a);
}
