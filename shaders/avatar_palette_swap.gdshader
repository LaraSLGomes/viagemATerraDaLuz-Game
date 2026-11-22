shader_type canvas_item;

uniform vec4 skin_color : source_color = vec4(0.92, 0.76, 0.62, 1.0);
uniform vec4 hair_color : source_color = vec4(0.22, 0.14, 0.08, 1.0);
uniform vec4 shirt_color : source_color = vec4(0.85, 0.15, 0.15, 1.0);
uniform vec4 pants_color : source_color = vec4(0.15, 0.35, 0.75, 1.0);
uniform vec4 shoe_color : source_color = vec4(0.95, 0.85, 0.20, 1.0);
uniform vec4 backpack_color : source_color = vec4(0.20, 0.70, 0.25, 1.0);

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (tex_color.a < 0.05) {
		COLOR = vec4(0.0);
		return;
	}
	
	vec3 rgb = tex_color.rgb;
	float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
	
	// Outlines and very dark tones (eyes, pupils, black borders)
	if (lum < 0.12 && max(max(rgb.r, rgb.g), rgb.b) < 0.18) {
		COLOR = tex_color;
		return;
	}
	
	vec3 hsv = rgb_to_hsv(rgb);
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;
	
	vec4 target_color = tex_color;
	bool matched = false;
	
	// 1. Cabelo: branco / cinza claro
	if (s < 0.15 && v > 0.40) {
		float shade = v;
		target_color = vec4(hair_color.rgb * shade, tex_color.a);
		matched = true;
	}
	// 2. Blusa: vermelho vivo
	else if ((h < 0.04 || h > 0.94) && s > 0.45) {
		float shade = lum / 0.50;
		target_color = vec4(shirt_color.rgb * shade, tex_color.a);
		matched = true;
	}
	// 3. Calça: azul vivo
	else if (h >= 0.54 && h <= 0.70 && s > 0.35) {
		float shade = lum / 0.42;
		target_color = vec4(pants_color.rgb * shade, tex_color.a);
		matched = true;
	}
	// 4. Sapato: amarelo vivo
	else if (h >= 0.09 && h <= 0.20 && s > 0.40) {
		float shade = lum / 0.70;
		target_color = vec4(shoe_color.rgb * shade, tex_color.a);
		matched = true;
	}
	// 5. Mochila: verde vivo
	else if (h >= 0.22 && h <= 0.45 && s > 0.30) {
		float shade = lum / 0.45;
		target_color = vec4(backpack_color.rgb * shade, tex_color.a);
		matched = true;
	}
	// 6. Pele: tom bege/alaranjado
	else if (h >= 0.035 && h <= 0.115 && s >= 0.18 && s <= 0.75) {
		float shade = lum / 0.65;
		target_color = vec4(skin_color.rgb * shade, tex_color.a);
		matched = true;
	}
	
	if (matched) {
		target_color.rgb = clamp(target_color.rgb, 0.0, 1.0);
		COLOR = target_color;
	} else {
		COLOR = tex_color;
	}
}
