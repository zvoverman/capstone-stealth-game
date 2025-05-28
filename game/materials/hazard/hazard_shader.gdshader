shader_type spatial;
render_mode unshaded;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void vertex() {
	VERTEX += NORMAL * (sin(TIME) / 10.0 + 0.1);
}

void fragment() {
	vec2 st = UV * 10.0;
    float time = TIME / 4.0;
    
    vec3 color = vec3(0.0);
    
    // Cell position
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);
    
    float min_dist = 1.0;
    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            vec2 neighbor = vec2(float(x), float(y));
            
            vec2 cell = random2(i_st + neighbor);
            
            cell = 0.5 + 0.5 * sin(time + cell * 10.0);
            
            float dist = distance(f_st, neighbor + cell);
            
            min_dist = min(min_dist, min_dist * dist);
        }
    }
	
    color[0] = 1.0 - smoothstep(1.0, 1.2, min_dist);
	color[1] = 1.0 - smoothstep(0.1, 0.3, min_dist);
    
    ALBEDO = color;
}
