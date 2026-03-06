shader_type canvas_item;

uniform bool render_front = true;
uniform float circle_width: hint_range(0.0, 1.0) = 0.5;
uniform float circle_distance: hint_range(0.0, 1.0) = 0.5;

float create_cicles(vec2 uv, vec4 fragcoord) {
	float outer_circle = step(distance(uv * vec2(1.0, 2.0) - vec2(0.,.5), vec2(0.5)), circle_distance * .5);
	
	float inner_cicle = step(distance(uv * vec2(1.0, 2.0) - vec2(0.,.5), vec2(0.5)), (circle_distance * .5 - circle_width * 0.05));
	
	bool front_half = fragcoord.y - 330. > 0.0;
	if (render_front != front_half) {
        discard;
    }
	return max(outer_circle - inner_cicle, 0.);
}

void fragment() {
	COLOR.xyz = vec3(0.294, 0.447, 0.431);
	COLOR.a = create_cicles(UV, FRAGCOORD);
}
