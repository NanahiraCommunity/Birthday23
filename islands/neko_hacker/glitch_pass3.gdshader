shader_type spatial;

render_mode blend_add,depth_draw_always,cull_disabled,unshaded,world_vertex_coords;

global uniform vec3 player_world_position;

uniform float ring_size = 0.5;
uniform float ring_width = 0.02;

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
	float player_distance = d;
	float ring_size_norm = ring_size;
	float ring_width_norm = ring_width;
	if (distance(player_distance, ring_size_norm) < ring_width_norm) {
		ALBEDO = vec3(pow(1.0 - distance(player_distance, ring_size_norm) / ring_width_norm, 2.0), 0, 0);
		ALPHA = 1.0;
	} else {
		discard;
	}
}
