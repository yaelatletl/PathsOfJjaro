shader_type spatial;
uniform float iorRatioR;
uniform float iorRatioG;
uniform float iorRatioB;

void fragment(){ 
	float depth = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
	vec3 view = normalize((INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth*2.0-1.0,1.0)).xyz);
	
	vec3 refractVecR = refract(view, NORMAL, iorRatioR);
	vec3 refractVecG = refract(view, NORMAL, iorRatioG);
	vec3 refractVecB = refract(view, NORMAL, iorRatioB);
     
    
   // COLOR.r = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecR.xy).r;
    //COLOR.g = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecG.xy).g;
    //COLOR.b = texture(SCREEN_TEXTURE, SCREEN_UV + refractVecB.xy).b;
    //COLOR.a = 1.0;
	}