shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform vec3 glow_color : source_color;
uniform float glow_strength : hint_range(0,10);
uniform float glow_falloff : hint_range(0.5,2);
uniform float glow_size;

varying vec4 flattened;

vec3 project(vec3 p, vec3 n)
{
	return p - dot(p, n) * n;
}

void vertex() {
	flattened = vec4(project((MODEL_MATRIX * vec4(VERTEX, 0.0)).xyz, normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD)), 1.0) * VIEW_MATRIX;
}

void fragment() {
	ALBEDO = glow_color * glow_strength;
	ALPHA = pow(max(0.0, glow_size - length(flattened.xyz)), glow_falloff);
}
