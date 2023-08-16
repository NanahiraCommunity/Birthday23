shader_type spatial;

varying vec3 coords;

uniform float multiplier = 1.0;
uniform float height;

void vertex() {
	coords = VERTEX;
}

void fragment() {
	ALBEDO = vec3(0);
	EMISSION = vec3(1.5);
	ALPHA = pow(clamp(coords.y / height + 0.5, 0.0, 1.0), 2.0) * multiplier;
}
