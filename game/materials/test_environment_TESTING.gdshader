shader_type canvas_item;

uniform float dither_strength : hint_range(0.0, 1.0) = 0.5;  // Controls how strong the dithering effect is
uniform sampler2D noise_texture : repeat_enable;  // A noise texture to use for dithering
uniform int color_levels : hint_range(2, 256) = 8;  // Number of quantization levels (2 to 256)

void fragment() {
    // Get the original color of the pixel
    vec4 original_color = texture(TEXTURE, UV);
    
    // Quantize the color by dividing and multiplying with the number of levels
    vec3 quantized_color = floor(original_color.rgb * float(color_levels)) / float(color_levels);
    
    // Generate a dither value from the noise texture, scaled for better detail
    float dither_value = texture(noise_texture, UV * 10.0).r;  // The *10.0 scales the noise for better detail
    
    // Apply dithering: smooth transition between quantized values based on noise
    vec3 dithered_color = quantized_color + (dither_value - 0.5) * dither_strength / float(color_levels);
    
    // Output the dithered color, preserving the original alpha
    COLOR = vec4(dithered_color, original_color.a);
}
