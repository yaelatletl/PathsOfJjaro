// NOTE: Shader automatically converted from Godot Engine 3.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx, unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_refraction;
uniform float refraction : hint_range(-16,16);
uniform vec4 refraction_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}




void fragment() {
	vec2 base_uv = UV;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	vec3 depth = texture(DEPTH_TEXTURE, SCREEN_UV).rgb;
	vec3 ref_normal = NORMAL;
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * dot(texture(texture_refraction,SCREEN_UV),refraction_texture_channel) * refraction;
	vec4 albedo_tex = textureLod(SCREEN_TEXTURE,ref_ofs,0);
	ALBEDO = albedo_tex.rgb;
	float ref_amount = 1.0 - albedo.a * albedo_tex.a;
	//ALBEDO = textureLod(SCREEN_TEXTURE,ref_ofs,1.0).rgb * ref_amount;
	
	ALPHA = 1.0;
}
