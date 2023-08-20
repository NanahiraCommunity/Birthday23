shader_type spatial;
render_mode unshaded, blend_add;

void vertex() {
	float rot = TIME;
	mat3 rotm = mat3(
		vec3(sin(rot), 0.0, -cos(rot)),
		vec3(0.0, 1.0, 0.0),
		vec3(cos(rot), 0.0, sin(rot))
	) * mat3(
		vec3(sin(rot), -cos(rot), 0.0),
		vec3(cos(rot), sin(rot), 0.0),
		vec3(0.0, 0.0, 1.0)
	);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(rotm);
}

void fragment() {
	ALBEDO = vec3(0, 1, 0);
}
