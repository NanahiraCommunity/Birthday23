shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

varying vec3 world_pos;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

uniform vec3 light_brown : source_color = vec3(0.701102, 0.412542, 0.168269);
uniform vec3 dark_brown : source_color = vec3(0.590619, 0.332451, 0.111932);
uniform vec3 darker_brown : source_color = vec3(0.3, 0.165, 0.055);
uniform vec3 darkest_brown : source_color = vec3(0.2, 0.1, 0.03);

vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
	vec3 Pi0 = floor(P); // Integer part for indexing
	vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
	Pi0 = mod(Pi0, 289.0);
	Pi1 = mod(Pi1, 289.0);
	vec3 Pf0 = fract(P); // Fractional part for interpolation
	vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
	vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	vec4 iy = vec4(Pi0.yy, Pi1.yy);
	vec4 iz0 = Pi0.zzzz;
	vec4 iz1 = Pi1.zzzz;

	vec4 ixy = permute(permute(ix) + iy);
	vec4 ixy0 = permute(ixy + iz0);
	vec4 ixy1 = permute(ixy + iz1);

	vec4 gx0 = ixy0 / 7.0;
	vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
	gx0 = fract(gx0);
	vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
	vec4 sz0 = step(gz0, vec4(0.0));
	gx0 -= sz0 * (step(0.0, gx0) - 0.5);
	gy0 -= sz0 * (step(0.0, gy0) - 0.5);

	vec4 gx1 = ixy1 / 7.0;
	vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
	gx1 = fract(gx1);
	vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
	vec4 sz1 = step(gz1, vec4(0.0));
	gx1 -= sz1 * (step(0.0, gx1) - 0.5);
	gy1 -= sz1 * (step(0.0, gy1) - 0.5);

	vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
	vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
	vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
	vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
	vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
	vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
	vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
	vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

	vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;

	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
	float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
	float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
	float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
	float n111 = dot(g111, Pf1);

	vec3 fade_xyz = fade(Pf0);
	vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
	vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
	return 2.2 * n_xyz;
}


void vertex() {
	//VERTEX = vec3(VERTEX.x, VERTEX.y, VERTEX.z);
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
		float y = 1.0 - fract(world_pos.y / 0.1);

		vec2 evenodd = fract(UV * 5.0);
	vec2 uv = fract(UV * 10.0);
		
		float n = cnoise(vec3(UV.x, world_pos.y, UV.y) * 30.0)
		+ cnoise(vec3(UV.y, world_pos.y, UV.x) * 80.0) * 0.5
		+ cnoise(vec3(UV.x, world_pos.y, UV.y) * 170.0) * 0.25;
		
		vec3 SideUV = vec3(evenodd.x, (y - 0.1) / 0.8, evenodd.y);
		//vec3 SideUV = vec3(evenodd.x, y, evenodd.y);
		
		vec3 m;
		if (y < 0.1)
				m = mix(mix(light_brown.x, dark_brown.x, pow(1.0 - evenodd.x, 4)),
								darker_brown.x, y / 0.1) * texture(texture_albedo, UV).xyz;
		else if (y > 0.9)
				m = mix(mix(light_brown, dark_brown, pow(1.0 - fract(evenodd.x + 0.5), 4.0)),
								darker_brown, 1.0 - ((y-0.9) / 0.1));
		else
		{
		float heightmap_scale = 6.5;
		int it = 0;
		vec2 base_uv = SideUV.xy;
		{
			vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT,-BINORMAL,NORMAL));
			for (; it < 20; it++)
			{
				float depth = clamp(
					pow(abs(pow(sin(base_uv.x * 3.1415926), 2.0) - clamp(base_uv.y, 0, 1)) * 4.0, 2.0)
					, 0, 1);
				vec2 ofs = base_uv - view_dir.xy * depth * heightmap_scale * 0.01;
				if (length(base_uv - ofs) < 0.01)
					break;
				base_uv=ofs;
			}
		}
		y = base_uv.y;
				m = mix(light_brown, darkest_brown, clamp(
			pow(abs(pow(sin(base_uv.x * 3.1415926), 2.0) - clamp(base_uv.y, 0, 1)) * 4.0, 2.0)
			+ pow(float(it) / 20.0, 0.75), 0, 1));
		}
		
		ALBEDO = mix(m, darker_brown, n * 0.15);
	ROUGHNESS = 0.7;
	SPECULAR = 0.15;
}
