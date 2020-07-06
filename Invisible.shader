shader_type spatial;
render_mode depth_draw_always, unshaded;

uniform float lod = 1.0000;
uniform float eta = 0.99000;

void vertex() {
// Output:0

}

void fragment() {
// Input:3
	vec3 screen;
	mat4 aaa = CAMERA_MATRIX * INV_CAMERA_MATRIX;
	screen = vec3(SCREEN_UV,0.0);

// Texture:18
	vec3 n_out18p0;
	float n_out18p1;
	{
		vec4 _tex_read = textureLod( SCREEN_TEXTURE , screen.xy , lod );
		n_out18p0 = _tex_read.rgb;
		n_out18p1 = _tex_read.a;
	}




// Refract:7

	vec3 n_out7p0;
	n_out7p0 = refract( ( INV_CAMERA_MATRIX * vec4(( INV_PROJECTION_MATRIX * vec4(vec3(SCREEN_UV,0.0), 1.0) ).xyz, 1.0) ).xyz, NORMAL, eta );

// TransformVectorMult:13
	vec3 n_out13p0;
	n_out13p0 = ( CAMERA_MATRIX * vec4(n_out7p0, 1.0) ).xyz;

// TransformVectorMult:20
	vec3 n_out20p0;
	n_out20p0 = ( PROJECTION_MATRIX * vec4(n_out13p0, 1.0) ).xyz;

// Texture:10
	vec3 n_out10p0;
	float n_out10p1;
	{
		vec4 _tex_read = textureLod( SCREEN_TEXTURE , n_out20p0.xy , lod );
		n_out10p0 = _tex_read.rgb;
		n_out10p1 = _tex_read.a;
	}

// ColorOp:16
	vec3 n_out16p0;
	{
		float base=n_out18p0.x;
		float blend=n_out10p0.x;
		if (base < 0.5) {
			n_out16p0.x = (base * (2.0*blend));
		} else {
			n_out16p0.x = (1.0 - (1.0-base) * (1.0-2.0*(blend-0.5)));
		}
	}
	{
		float base=n_out18p0.y;
		float blend=n_out10p0.y;
		if (base < 0.5) {
			n_out16p0.y = (base * (2.0*blend));
		} else {
			n_out16p0.y = (1.0 - (1.0-base) * (1.0-2.0*(blend-0.5)));
		}
	}
	{
		float base=n_out18p0.z;
		float blend=n_out10p0.z;
		if (base < 0.5) {
			n_out16p0.z = (base * (2.0*blend));
		} else {
			n_out16p0.z = (1.0 - (1.0-base) * (1.0-2.0*(blend-0.5)));
		}
	}
	vec3 world_camera = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 world_pos = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = clamp(0,1,distance(world_camera, world_pos)/10.0);
// Scalar:22
	float n_out22p0;
	n_out22p0 = 0.000000;
	vec3 middle = mix(n_out10p0, n_out18p0, dist);
// Output:0
//	ALBEDO = n_out16p0;
	ALBEDO = middle/4.0;
	METALLIC = n_out22p0;
	ROUGHNESS = lod;

}

void light() {
// Output:0

}
