shader_type spatial;
render_mode unshaded, world_vertex_coords;

const vec3 HIGHLIGHT_COLOR = vec3(0.0, 1.0, 0.0);
const float HIGHLIGHT_SMOOTHNESS = 2.0;
const float HIGHLIGHT_SPEED = 20.0;
const float MAX_DIST = 1000.0;

uniform float visibility = 0.0;
uniform vec3 start_position = vec3(0.0);
uniform float time = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = VERTEX;
	VERTEX = VERTEX + (NORMAL * 0.01);
}

void fragment() {
	float dist = distance(world_position, start_position);
	float effect_time = time * HIGHLIGHT_SPEED;
	
	float percent = 1.0 - smoothstep(-HIGHLIGHT_SMOOTHNESS, HIGHLIGHT_SMOOTHNESS, dist - effect_time);
	
	ALBEDO = HIGHLIGHT_COLOR * percent;
	
	ALPHA = 0.25 * percent * visibility;
}
