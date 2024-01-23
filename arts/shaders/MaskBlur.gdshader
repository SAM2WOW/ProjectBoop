shader_type canvas_item;

// Input textures
uniform sampler2D main_texture;
uniform sampler2D mask_texture;
uniform float alpha = 1;

uniform int strength: hint_range(1, 512) = 2;
uniform vec4 mod_color = vec4(1, 0, 0, 1);

vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);	

    vec2 pixel = fragCoord/pixelSize;
    int x_min = max(int(pixel.x-strengthFloat), 0);
    int x_max = min(int(pixel.x+strengthFloat), int(1./pixelSize.x));
    int y_min = max(int(pixel.y-strengthFloat), 0);
    int y_max = min(int(pixel.y+strengthFloat), int(1./pixelSize.y));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {           
            color += texture(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }
    
    // Divide the color by the number of colors you summed up
    color /= float(count);
    
    return color;
}

void fragment() {
    // Get the color of the main image
    //vec4 main_color = texture(main_texture, UV);
	vec4 main_color = blur_size(TEXTURE,UV,TEXTURE_PIXEL_SIZE) * mod_color;

    // Get the grayscale value from the mask
    float mask_value = texture(mask_texture, SCREEN_UV).r;

    // Use the mask value to determine the final color
    // You can customize this based on your needs
    main_color.a *= mask_value * alpha;

    // Output the final color
    COLOR = main_color;
}