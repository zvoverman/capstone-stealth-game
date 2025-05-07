shader_type spatial;

uniform int visible_flag = 0;

void fragment() {
	
	if (visible_flag == 0)
		discard;
	
	ALBEDO = vec3(1.0, 0.92, 0.59);
	ALPHA = 0.5;
	EMISSION = vec3(0.1, 0.1, 0.1);
}
