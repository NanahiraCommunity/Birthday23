shader_type spatial;
render_mode specular_toon, cull_disabled, depth_draw_always;

uniform vec3 water_color : source_color;

varying vec3 model_normal;
varying vec3 view_normal;

void vertex() {
	model_normal = NORMAL;
	view_normal = mat3(MODELVIEW_MATRIX) * NORMAL;
}

void fragment() {
	vec2 uv = UV + vec2(TIME * 0.03, sin(TIME * 0.5 * 0.1) * 0.5);
	SPECULAR = 1.0;
	ROUGHNESS = 0.1;
	if (model_normal.y > 0.5)
	{
		float t = TIME;
		RIM = 0.5;
		// water surface
		ALBEDO = water_color;
		NORMAL = normalize(
			normalize(vec3(cos(uv.x + t), 5.0, sin(uv.y + t)))
			+ normalize(vec3(sin(uv.x * 0.5 + t * 2.0), 10.0, cos(uv.y * 0.5 + t * 2.0)))
			+ normalize(vec3(sin(uv.x * 0.25 + t * 4.0), 20.0, cos(uv.y * 0.25 + t * 4.0)))
			+ normalize(vec3(cos(uv.x * 0.25 + t * 4.0), 20.0, sin(uv.y * 0.25 + t * 4.0)))
		);
	}
	else
	{
		uv.y = UV.y;
		RIM = 0.5;
		NORMAL = normalize(view_normal + vec3(0, 1.0, 0));
		// waterfalls
		ALBEDO = mix(water_color, vec3(1.0), pow(1.0 - UV.y, 4.0));
		float wave = sin(uv.x * TAU * 10.0);
		float foam = 0.2 + wave * 0.01;
		if (uv.y < foam - 0.1 - wave * 0.02)
			discard;
		else if (uv.y < foam)
			EMISSION = vec3(0.5 * pow((foam - uv.y) / foam * 0.5, 0.5));
	}
}
