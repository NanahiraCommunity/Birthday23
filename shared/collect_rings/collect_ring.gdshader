shader_type spatial;
render_mode unshaded, blend_add;

uniform float distance_fade_min;
uniform float distance_fade_max;
uniform vec3 color: source_color;
uniform bool collected = false;

void fragment() {
	ALBEDO = color * (collected ? vec3(0.2) : vec3(1.0));

	{
		float fade_distance = length((VIEW_MATRIX * MODEL_MATRIX[3]));
		const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
		float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}

}
