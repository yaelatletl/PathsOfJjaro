shader_type spatial;
render_mode skip_vertex_transform, unshaded, blend_add;

void vertex() {
	VERTEX = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.z += 0.95;
	VERTEX.xy *= 20.0;
}
uniform float iorRatioR=1.9;
uniform float iorRatioG=1.7;
uniform float iorRatioB=1.9;
uniform int ghosts = 4;
uniform float ghost_dispersal = 0.5;
uniform float halo_width = 0.25;
uniform float distort = 0.25;

uniform float bloom_scale = 10.0;
uniform float bloom_bias = 0.95;

uniform sampler2D lens_color;
uniform sampler2D lens_dirt: hint_white;



float weight(vec2 pos) {
	float w = length(vec2(0.5) - pos) / length(vec2(0.5));
	return pow(1.0 - w, 5.0);
}

vec4 bloomtex(in sampler2D tex, in vec2 texcoord, in float lod) {
	return max(vec4(0.0), texture(tex, texcoord, lod) - bloom_bias) * bloom_scale;
}

vec4 textureDistorted(in sampler2D tex, in vec2 texcoord, in vec2 direction, in vec3 distortion) {
	return vec4(
		bloomtex(tex, texcoord + direction * distortion.r, 2.0).r,
		bloomtex(tex, texcoord + direction * distortion.g, 2.0).g,
		bloomtex(tex, texcoord + direction * distortion.b, 2.0).b,
		1.0
	);
}

void fragment() {
	
	vec2 texcoord = 1.0 - SCREEN_UV;
	vec2 ghostVec = (vec2(0.5) - texcoord) * ghost_dispersal;
	
	float pixelSizeX = 1.0 / float(textureSize(SCREEN_TEXTURE, 0).x);
	
	vec3 distortion = vec3(-pixelSizeX * distort, 0.0, pixelSizeX * distort);
	vec2 direction = normalize(ghostVec);
	
	vec3 result = vec3(0.0);
	for(int i = 0; i < ghosts; ++i) {
		vec2 offset = fract(texcoord + ghostVec * float(i));
		result += textureDistorted(SCREEN_TEXTURE, offset, direction, distortion).rgb * weight(offset);
		}
	result *= texture(lens_color, vec2(length(vec2(0.5) - texcoord) / length(vec2(0.5)), 0)).rgb;
	
	
	vec2 haloVec = normalize(ghostVec) * halo_width;
	result += textureDistorted(SCREEN_TEXTURE, texcoord + haloVec, direction, distortion).rgb * weight(fract(texcoord + haloVec));
	
	
	vec3 distorted;
	float depth = textureLod(DEPTH_TEXTURE,SCREEN_UV,2.0).r;
	//vec3 view = normalize((INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth*2.0-1.0,1.0)).xyz);
	vec3 view = normalize((INV_PROJECTION_MATRIX*INV_CAMERA_MATRIX[1]).xyz);
	vec3 refractVecR = refract(view, NORMAL, iorRatioR);
	vec3 refractVecG = refract(view, NORMAL, iorRatioG);
	vec3 refractVecB = refract(view, NORMAL, iorRatioB);
     
    
    distorted.r = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecR.xy).r;
    distorted.g = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecG.xy).g;
    distorted.b = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecB.xy).b;
   
	ALBEDO = mix(distorted, result * mix(texture(lens_dirt, texcoord).rgb, vec3(0.5), 0.4), 0.5);
	//uncomment to debug bright point extraction
	//COLOR.rgba = bloomtex(SCREEN_TEXTURE, SCREEN_UV, 2.0);
}
