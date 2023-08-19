shader_type spatial;
render_mode blend_mix,unshaded,cull_back;

uniform vec3 glowstick_color : source_color;

void fragment() {
	ALBEDO = glowstick_color;
}
