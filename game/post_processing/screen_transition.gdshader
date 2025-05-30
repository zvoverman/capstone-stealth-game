shader_type canvas_item;

uniform float fade_progress: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float fade_softness: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    // Sample the original pixel
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    
    // Calculate luminance using standard weights
    float luminance = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Calculate fade factor based on luminance
    // Lighter pixels (higher luminance) appear first
    float fade_threshold = (1.0 - luminance) * (1.0 - fade_progress);
    
    // Apply smoothstep for soft transition
    float fade_factor = smoothstep(fade_threshold - fade_softness, fade_threshold + fade_softness, fade_progress);
    
    // Mix between black and original color
    COLOR = vec4(mix(vec3(0.0), original_color.rgb, fade_factor), original_color.a);
}