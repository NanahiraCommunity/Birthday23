// same as paper_material.gdshader, but with cull_back instead of cull_disabled

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 paper_color : source_color;
uniform bool paper_color_both_sides;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D texture_paper : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	float paper_amount = 0.556;
	vec2 base_uv = UV;
	vec4 albedo_tex = (texture(texture_albedo, base_uv) * vec4(vec3(paper_amount), 1.0)
		+ vec4(vec3(1.0 - paper_amount), 0.0))
		* (FRONT_FACING ? paper_color * texture(texture_paper, base_uv)
				: (paper_color_both_sides ? paper_color : vec4(1.0)));
	ALBEDO = albedo_tex.rgb;
	METALLIC = 0.0;
	float roughness_tex = texture(texture_roughness,base_uv).r;
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}
