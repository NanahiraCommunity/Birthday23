shader_type particles;

uniform float jiggle;
uniform float speed;
uniform vec3 emission_box_extents;
uniform float corner_affinity : hint_range(0.0, 1.0, 0.01);
uniform sampler2D color_ramp : repeat_disable;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);

	if (RESTART_VELOCITY) {
		float tex_linear_velocity = 1.0;
		{
			float angle1_rad = rand_from_seed_m1_p1(alt_seed) * TAU;
			CUSTOM.w = angle1_rad;
			vec3 rot = vec3(cos(angle1_rad), 0.0, sin(angle1_rad));
			VELOCITY = rot * speed;
		}
	}

	CUSTOM.x = 0.0;
	CUSTOM.y = float(NUMBER);

	if (RESTART_ROT_SCALE) {
		TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
		TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
		TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);
	}

	if (RESTART_POSITION) {
		TRANSFORM[3].xyz = vec3(
			sign(rand_from_seed(alt_seed) - 0.5) * pow(rand_from_seed(alt_seed), 1.0 - corner_affinity),
			0.0,
			sign(rand_from_seed(alt_seed) - 0.5) * pow(rand_from_seed(alt_seed), 1.0 - corner_affinity)
		) * emission_box_extents;
		if (RESTART_VELOCITY) VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz * speed;
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}
}

mat3 rot_y(float rot) {
	return mat3(
		vec3(cos(rot), 0.0, -sin(rot)),
		vec3(0.0, 1.0, 0.0),
		vec3(sin(rot), 0.0, cos(rot))
	);
}

void process() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED + uint(CUSTOM.y));
	float x = rand_from_seed(alt_seed);
	float y = rand_from_seed(alt_seed);
	CUSTOM.y = float(alt_seed);

	if (CUSTOM.x == 0.0) {
		emit_subparticle(TRANSFORM, mat3(EMISSION_TRANSFORM) * vec3(x - 0.5, 2.0, y - 0.5),vec4(0.0),vec4(0.0),FLAG_EMIT_POSITION|FLAG_EMIT_VELOCITY);
	}

	CUSTOM.x += DELTA / LIFETIME;
	CUSTOM.z += DELTA / LIFETIME;
	COLOR = textureLod(color_ramp, vec2(CUSTOM.x, 0.0), 0.0);

	float dr = 0.2 * sign(CUSTOM.z - 0.05);
	CUSTOM.w += dr;
	VELOCITY = rot_y(dr) * VELOCITY;
	if (CUSTOM.z > 0.1) {
		CUSTOM.z -= 0.1;
		dr = rand_from_seed(alt_seed) * PI;
		CUSTOM.w += dr;
		if (mod(CUSTOM.x * 10.0, 6.0) <= 0.5)
			emit_subparticle(TRANSFORM, mat3(EMISSION_TRANSFORM) * vec3(0.0, 1.0, 0.0),vec4(0.0),vec4(0.0),FLAG_EMIT_POSITION|FLAG_EMIT_VELOCITY);
	}
	vec3 rot = vec3(cos(CUSTOM.w), 0.0, sin(CUSTOM.w));
	VELOCITY = mat3(EMISSION_TRANSFORM) * (rot * speed);

	mat3 rotmat = mat3(EMISSION_TRANSFORM) * rot_y(-CUSTOM.w - dr);
	TRANSFORM[0] = vec4(rotmat[0], 0.0);
	TRANSFORM[1] = vec4(rotmat[1], 0.0);
	TRANSFORM[2] = vec4(rotmat[2], 0.0);
}

