shader_type spatial;
render_mode skip_vertex_transform, unshaded, blend_add;
uniform int ghosts = 4;
uniform float ghost_dispersal = 0.5;
uniform float halo_width = 0.25;
uniform float distort = 0.25;

uniform float bloom_scale = 10.0;
uniform float bloom_bias = 0.95;

uniform sampler2D lens_color;
uniform sampler2D lens_dirt: hint_white;
uniform sampler2D displace : hint_albedo;
uniform float dispAmt: hint_range(0,0.1);
uniform float abberationAmtX: hint_range(0,0.1);
uniform float abberationAmtY: hint_range(0,0.1);
uniform float dispSize: hint_range(0.1, 2.0);
uniform float maxAlpha : hint_range(0.1,1.0);

void vertex() {
VERTEX = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
VERTEX.z += 0.95;
VERTEX.xy *= 20.0;
}

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
result *= texture(lens_color, vec2(length(vec2(0.5) - texcoord) / length(vec2(0.5)), 0.0)).rgb;


vec2 haloVec = normalize(ghostVec) * halo_width;
result += textureDistorted(SCREEN_TEXTURE, texcoord + haloVec, direction, distortion).rgb * weight(fract(texcoord + haloVec));
vec3 RESULTATTO = result * mix(texture(lens_dirt, texcoord).rgb, vec3(0.5), 0.4);
	//displace effect
vec4 disp = texture(displace, SCREEN_UV * dispSize);
vec2 newUV = SCREEN_UV + disp.xy * dispAmt;
//abberation
vec3 DISP;
DISP.r = max(vec4(0.0), texture(SCREEN_TEXTURE, newUV - vec2(abberationAmtX,abberationAmtY), 1.0)).r; 
DISP.g = max(vec4(0.0), texture(SCREEN_TEXTURE, newUV, 1.0)).g; 
DISP.b = max(vec4(0.0), texture(SCREEN_TEXTURE, newUV + vec2(abberationAmtX,abberationAmtY), 1.0)).b;

//ALBEDO = textureLod(DEPTH_TEXTURE,SCREEN_UV, 1).rgb;
ALBEDO = RESULTATTO+DISP;
//ALBEDO = DISP;



//ALBEDO.a = texture(SCREEN_TEXTURE, newUV).a * maxAlpha;
}