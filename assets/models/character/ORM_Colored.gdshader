// NOTE: Shader automatically converted from Godot Engine 4.0.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_orm : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform float ao_light_affect;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}
void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 orm = texture(texture_orm, base_uv);
	ALBEDO = mix(albedo_tex.rgb, albedo_tex.rgb * albedo.rgb, orm.a);
	float metallic_tex = orm.b;
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(0.0,1.0,0.0,0.0);
	float roughness_tex = orm.g;
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	AO = orm.r;
	AO_LIGHT_AFFECT = ao_light_affect;
}
