shader_type spatial;

uniform vec3 glowstick_color : source_color;

void fragment() {
	ALBEDO = vec3(0);
	EMISSION = glowstick_color;
}
