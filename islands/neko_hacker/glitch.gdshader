shader_type spatial;

render_mode blend_mix,depth_draw_never,cull_disabled,unshaded,world_vertex_coords;

uniform sampler2D viewport : source_color, hint_default_black,filter_linear_mipmap,repeat_enable;
uniform sampler2D binary_texture : source_color, hint_default_black,filter_linear_mipmap,repeat_enable;
uniform sampler2D fresnel_color : source_color, hint_default_black, filter_nearest, repeat_enable;
uniform vec2 screen_segments = vec2(10.0, 20.0);
uniform float opacity = 1.0;

uniform float bpm = 147.0;
uniform float bpm_offset_s = -3.45;
uniform float max_pixel_offset = 4;
uniform float pixel_drift = 2;

varying vec3 player_torso;

#define CPS (bpm / 60.0)

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

void fragment() {
	float beat = round((TIME + bpm_offset_s) * CPS);
	float binary01 = texture(binary_texture, SCREEN_UV * VIEWPORT_SIZE / vec2(510.0, 512.0) * 0.5).x;
	float fresnel = (1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0));
	vec2 random_offset = vec2(beat);
	vec2 uv = SCREEN_UV;
	uv += (vec2(random(round(uv * screen_segments) / screen_segments + random_offset) + pixel_drift * binary01 / VIEWPORT_SIZE.x, 0.4 + binary01 * 0.1) * 2.0 - vec2(1.0)) * (vec2(max_pixel_offset) / VIEWPORT_SIZE);
	vec3 emission_tex = texture(viewport, uv).rgb;
	ALBEDO = emission_tex
		+ texture(fresnel_color, vec2(beat * 0.25 * 0.25 + 0.125, 0.0)).xyz * (pow(fresnel, 3.0) + binary01 * 0.1);
	ALPHA = clamp(pow(fresnel, 0.2), 0.1, 0.8) * opacity;
}
