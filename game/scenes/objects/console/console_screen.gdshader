shader_type spatial;
render_mode unshaded;

uniform sampler2D display_texture;

const float curvature = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.z -= distance(UV, vec2(0.5)) * curvature;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(display_texture, UV).xyz;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
