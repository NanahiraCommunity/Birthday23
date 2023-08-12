shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform vec3 glow_color : source_color;
uniform float glow_strength : hint_range(0,10);
uniform float glow_falloff : hint_range(0.5,2);
uniform float glow_size;
uniform float glow_visibility : hint_range(0,1) = 1.0;

varying vec3 flattened;

vec3 project(vec3 p, vec3 n)
{
	return p - dot(p, n) * n;
}

void vertex() {
	vec4 v = MODEL_MATRIX * vec4(VERTEX, 1.0);
	flattened = project(mat3(MODEL_MATRIX) * VERTEX, normalize(CAMERA_POSITION_WORLD - v.xyz)) * mat3(VIEW_MATRIX);
}

void fragment() {
	ALBEDO = glow_color * glow_strength * max(1.0, glow_visibility - 1.0);
	ALPHA = min(1.0, pow(max(0.0, glow_size - length(flattened)), glow_falloff) * glow_visibility);
}
