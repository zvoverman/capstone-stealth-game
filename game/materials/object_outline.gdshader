shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color = vec4(0.81, 0.95, 0.02, 1.0); // Highlighter Yellow
uniform float outline_width = 2.0;

uniform int use_outline = 0; // 0 = off, 1 = on

void vertex()
{
	if (use_outline == 1)
	{
		vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
		vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
		
		clip_position.xy += normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
		
		POSITION = clip_position;
	}
}

void fragment()
{
	ALBEDO = outline_color.rgb;
	ALPHA = 1.0;
}