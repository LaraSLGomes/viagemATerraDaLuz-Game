extends Node2D
## Componente visual unificado do avatar adolescente.
## Utiliza um único Sprite2D com hframes=4, vframes=3,
## catálogo de spritesheets CompositeSprites e Shader de Palette Swap.
## Possui fallback de animação via código (_process) caso AnimationPlayer não esteja ativo.

const SHADER_PALETTE: Shader = preload("res://shaders/avatar_palette_swap.gdshader")

@onready var sprite_visual: Sprite2D = $SpriteVisual as Sprite2D
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer

var _sexo: String = "masculino"
var _estilo_cabelo: String = "curto"
var _animacao_atual: String = "idle_front"
var _olhando_esquerda: bool = false

# Controlador interno de frames para animação contínua e robusta
var _frame_timer: float = 0.0
var _frame_step: int = 0
const FRAME_DURATION: float = 0.15


func _ready() -> void:
	_garantir_shader_material()
	carregar_do_global()
	tocar_animacao("idle_front")


func _garantir_shader_material() -> void:
	if not is_instance_valid(sprite_visual):
		return
	var mat: ShaderMaterial = sprite_visual.material as ShaderMaterial
	if mat == null or mat.shader == null:
		var novo_mat: ShaderMaterial = ShaderMaterial.new()
		novo_mat.shader = SHADER_PALETTE
		novo_mat.resource_local_to_scene = true
		sprite_visual.material = novo_mat
	else:
		# Duplica para não compartilhar parâmetros entre instâncias diferentes
		sprite_visual.material = mat.duplicate()


func _process(delta: float) -> void:
	# Fallback de ciclo de passos por código se o AnimationPlayer não estiver tocando
	if not is_instance_valid(sprite_visual):
		return
	
	if is_instance_valid(anim_player) and anim_player.is_playing():
		return # AnimationPlayer está cuidando dos frames
		
	# Atualiza frames via código
	_frame_timer += delta
	if _frame_timer >= FRAME_DURATION:
		_frame_timer -= FRAME_DURATION
		_frame_step = (_frame_step + 1) % 4
		_atualizar_frame_manual()


func _atualizar_frame_manual() -> void:
	if not is_instance_valid(sprite_visual):
		return
	match _animacao_atual:
		"idle_front":
			sprite_visual.frame = 0
		"walk_front":
			sprite_visual.frame = _frame_step
		"idle_side":
			sprite_visual.frame = 4
		"walk_side":
			sprite_visual.frame = 4 + _frame_step
		"idle_back":
			sprite_visual.frame = 8
		"walk_back":
			sprite_visual.frame = 8 + _frame_step
		_:
			sprite_visual.frame = 0


func carregar_do_global() -> void:
	if not Engine.has_singleton("Global") and not has_node("/root/Global"):
		return
	var g: Node = get_node("/root/Global")
	
	var sexo_atual: String = g.sexo if "sexo" in g else "masculino"
	var estilo_atual: String = g.estilo_cabelo if "estilo_cabelo" in g else "curto"
	
	var config: Dictionary = {
		"sexo": sexo_atual,
		"estilo_cabelo": estilo_atual,
		"cor_pele": g.cor_pele if "cor_pele" in g else Color(0.92, 0.76, 0.62),
		"cor_cabelo": g.cor_cabelo if "cor_cabelo" in g else Color(0.22, 0.14, 0.08),
		"cor_blusa": g.cor_blusa if "cor_blusa" in g else Color(0.85, 0.15, 0.15),
		"cor_calca": g.cor_calca if "cor_calca" in g else Color(0.15, 0.35, 0.75),
		"cor_sapato": g.cor_sapato if "cor_sapato" in g else Color(0.95, 0.85, 0.20),
		"cor_mochila": g.cor_mochila if "cor_mochila" in g else Color(0.20, 0.70, 0.25)
	}
	aplicar_configuracao(config)


func aplicar_configuracao(c: Dictionary) -> void:
	_garantir_shader_material()
	_sexo = c.get("sexo", "masculino")
	_estilo_cabelo = c.get("estilo_cabelo", "curto")
	
	# 1. Carrega spritesheet correspondente do CompositeSprites
	var tex: Texture2D = CompositeSprites.obter_spritesheet(_sexo, _estilo_cabelo)
	if is_instance_valid(sprite_visual) and tex != null:
		sprite_visual.texture = tex
		
		# 2. Aplica as cores no ShaderMaterial
		var mat: ShaderMaterial = sprite_visual.material as ShaderMaterial
		if mat:
			if c.has("cor_pele"):
				mat.set_shader_parameter("skin_color", c["cor_pele"])
			if c.has("cor_cabelo"):
				mat.set_shader_parameter("hair_color", c["cor_cabelo"])
			if c.has("cor_blusa"):
				mat.set_shader_parameter("shirt_color", c["cor_blusa"])
			if c.has("cor_calca"):
				mat.set_shader_parameter("pants_color", c["cor_calca"])
			if c.has("cor_sapato"):
				mat.set_shader_parameter("shoe_color", c["cor_sapato"])
			if c.has("cor_mochila"):
				mat.set_shader_parameter("backpack_color", c["cor_mochila"])


func tocar_animacao(nome: String) -> void:
	_animacao_atual = nome
	if is_instance_valid(anim_player) and anim_player.has_animation(nome):
		if anim_player.current_animation != nome or not anim_player.is_playing():
			anim_player.play(nome)
	else:
		_atualizar_frame_manual()


func definir_movimento(vel: Vector2) -> void:
	if vel.length() < 5.0:
		if _animacao_atual.begins_with("walk_back") or _animacao_atual == "idle_back":
			tocar_animacao("idle_back")
		elif _animacao_atual.begins_with("walk_side") or _animacao_atual == "idle_side":
			tocar_animacao("idle_side")
		else:
			tocar_animacao("idle_front")
		return

	if abs(vel.x) > 10.0:
		definir_espelhamento(vel.x < 0.0)
		tocar_animacao("walk_side")
	elif vel.y < -10.0:
		tocar_animacao("walk_back")
	elif vel.y > 10.0:
		tocar_animacao("walk_front")


func definir_animacao_andando(andando: bool) -> void:
	if andando:
		tocar_animacao("walk_side")
	else:
		tocar_animacao("idle_side" if _animacao_atual.contains("side") else "idle_front")


func definir_espelhamento(olhando_esquerda: bool) -> void:
	_olhando_esquerda = olhando_esquerda
	if is_instance_valid(sprite_visual):
		sprite_visual.flip_h = olhando_esquerda
