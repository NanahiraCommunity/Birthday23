shader_type spatial;

render_mode blend_sub,depth_draw_always,cull_disabled,unshaded,world_vertex_coords;

global uniform vec3 player_world_position;

uniform float player_sphere_distance = 0.7;

varying vec3 vertex_pos;
varying vec3 player_torso;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

void vertex() {
	player_torso = player_world_position + vec3(0, 0.2, 0);
	vertex_pos = VERTEX;
}

void fragment() {
	vec3 dir = vertex_pos - player_torso;
	float d = length(dir);
	float player_distance = d / player_sphere_distance;
	if (player_distance < 1.0) {
		ALBEDO = vec3(0, 2, 2) * random(SCREEN_UV) * (1.0 - pow(player_distance, 1.0));
		ALPHA = 1.0;
	} else {
		discard;
	}
}
