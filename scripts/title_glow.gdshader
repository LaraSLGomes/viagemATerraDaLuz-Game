shader_type canvas_item;
render_mode blend_add, unshaded;

void fragment() {
	float center_x = 0.505 + sin(TIME * 0.48) * 0.002;
	float distance_from_portal = abs(UV.x - center_x);
	float core = exp(-pow(distance_from_portal / 0.012, 2.0));
	float halo = exp(-pow(distance_from_portal / 0.065, 2.0));
	float pulse = 0.72 + 0.28 * sin(TIME * 1.25);
	float shimmer = 0.82 + 0.18 * sin(TIME * 3.1 - UV.y * 18.0);
	float intensity = (halo * 0.10 + core * 0.36) * pulse * shimmer;
	vec3 warm = vec3(1.0, 0.43, 0.10);
	vec3 cyan = vec3(0.12, 0.88, 0.91);
	vec3 glow_color = mix(warm, cyan, clamp(core * 1.15, 0.0, 1.0));
	COLOR = vec4(glow_color * intensity, intensity);
}
