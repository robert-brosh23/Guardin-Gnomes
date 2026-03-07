shader_type canvas_item;

uniform float speed = 6.0;

void fragment(){
	if (INSTANCE_CUSTOM.z > 0.5) {
    	vec4 tex = texture(TEXTURE, UV);

	    float blink = step(0.5, sin(TIME * speed) * 0.5 + 0.5);

	    COLOR = tex * blink;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
