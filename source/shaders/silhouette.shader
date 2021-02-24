shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color: hint_color = vec4(1.0,1.0,1.0,1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float alpha = col.a;
	col = mix(col, color, color.a);
	col.a = alpha;
	COLOR = col;
}