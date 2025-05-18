shader_type canvas_item;

uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 50.0) = 10.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 1.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Create a wobble effect using a sine wave
    uv.y += sin(uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    uv.x += cos(uv.y * wave_frequency + TIME * wave_speed) * wave_amplitude;

    COLOR = texture(SCREEN_TEXTURE, uv);
}
