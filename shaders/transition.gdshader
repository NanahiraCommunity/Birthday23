shader_type canvas_item;

uniform float circle_size: hint_range(0.0, 1.0);
uniform float blur = 3.0;
uniform ivec2 center = ivec2(0,0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	if (circle_size > 0.0)
	{
		COLOR.w = 0.0;
		ivec2 size = textureSize(SCREEN_TEXTURE, 0);
		float diagonal = length(vec2(size));
		ivec2 pixel_position = ivec2(FRAGCOORD.xy);
		float radius = diagonal * circle_size;
		
		float distance_from_center = length(vec2(center - pixel_position));
		if (distance_from_center > radius)
		{
			float amount = abs(distance_from_center - radius)/blur;
			COLOR.w = amount;
		}
	}
	else
	{
		COLOR.w = 1.0;
	}
}
