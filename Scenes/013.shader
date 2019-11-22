shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx,cull_disabled;
uniform vec4 albedo : hint_color;
uniform vec4 albedo2 : hint_color;
uniform vec4 albedo3 : hint_color;
uniform sampler2D texture_albedo : hint_white;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	vec2 UV3= UV;
	vec3 output = vec3(0.0,1.0,0.0);
	UV.x=UV.x*uv1_scale.x+fract(uv1_offset.x+0.2*TIME);
	
	output -= NORMAL*5.0*min(texture(texture_albedo, UV).g, 10);
	output -= NORMAL*5.0*texture(texture_albedo, 0.01*vec2(3.0*cos(TIME+UV3.x), 0.05*cos(TIME*UV.y))).r;
	
	VERTEX += output;
}




void fragment() {
	vec2 base_uv =UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 albedo_tex2 = texture(texture_albedo,4.0*base_uv);
	vec3 mixed = mix(albedo2* albedo_tex2.r, albedo3*albedo_tex.r, albedo_tex2).rgb;//, ).rgb;
	ALBEDO =  mix(albedo.rgb,mixed, 1.5*albedo_tex.r);
	EMISSION = 2.0*ALBEDO;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = ALBEDO.r;
}
