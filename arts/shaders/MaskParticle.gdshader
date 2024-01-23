shader_type canvas_item;

// Input textures
uniform sampler2D mask_texture;
uniform float alpha = 1;

void fragment() {
    // Get the color of the main image
    vec4 main_color = COLOR;

    // Get the grayscale value from the mask
    float mask_value = texture(mask_texture, SCREEN_UV).r;

    // Use the mask value to determine the final color
    // You can customize this based on your needs
    main_color.a *= mask_value * alpha;

    // Output the final color
    COLOR = main_color;
}