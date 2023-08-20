shader_type spatial;

uniform sampler2D gradient : repeat_disable;
uniform vec3 fresnel_color : source_color;
uniform float scale;
uniform float power = 1.0;
uniform float fresnel_exp = 1.0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX * scale;
}

void fragment() {
	float fresnel = (1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0));
	ALBEDO = mix(texture(gradient, vec2(pow(length(local_pos), power), -local_pos.y + 0.5)).xyz, fresnel_color, pow(fresnel, fresnel_exp));
}
