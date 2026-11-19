extends Node2D
## Componente visual unificado e animado do avatar do jogador.
## Integra AnimatedSprite2D com os novos spritesheets de Menino e Menina
## e mantém compatibilidade com a personalização modular de roupas e acessórios.

const FRAMES_MENINO: SpriteFrames = preload("res://assets/Personagens/menino_frames.tres")
const FRAMES_MENINA: SpriteFrames = preload("res://assets/Personagens/menina_frames.tres")

@onready var anim_corpo: AnimatedSprite2D = $AnimatedSpriteCorpo as AnimatedSprite2D
@onready var spr_corpo: Sprite2D = get_node_or_null("Corpo") as Sprite2D
@onready var spr_mochila: Sprite2D = $Mochila as Sprite2D
@onready var spr_cabelo_tras: Sprite2D = $CabeloTras as Sprite2D
@onready var spr_calca: Sprite2D = $Calca as Sprite2D
@onready var spr_sapato: Sprite2D = $Sapato as Sprite2D
@onready var spr_blusa: Sprite2D = $Blusa as Sprite2D
@onready var spr_cabelo_frente: Sprite2D = $CabeloFrente as Sprite2D

var _sexo: String = "masculino"
var _olhando_esquerda: bool = false
var _animacao_atual: String = "idle"


func _ready() -> void:
	carregar_do_global()
	tocar_animacao("idle")


func carregar_do_global() -> void:
	if not Engine.has_singleton("Global") and not has_node("/root/Global"):
		return
	var g: Node = get_node("/root/Global")
	
	var tem_calca: bool = ("idx_calca" in g and g.idx_calca >= 0) or ("textura_calca" in g and str(g.textura_calca) != "")
	var sexo_atual: String = g.sexo if "sexo" in g else "masculino"
	
	var config: Dictionary = {
		"sexo": sexo_atual,
		"estilo_cabelo": g.estilo_cabelo if "estilo_cabelo" in g else "curto",
		"cor_pele": g.cor_pele if "cor_pele" in g else Color(0.92, 0.76, 0.62),
		"cor_cabelo": g.cor_cabelo if "cor_cabelo" in g else Color(0.22, 0.14, 0.08),
		"cor_blusa": g.cor_blusa if "cor_blusa" in g else Color.WHITE,
		"cor_calca": g.cor_calca if "cor_calca" in g else Color.WHITE,
		"cor_sapato": g.cor_sapato if "cor_sapato" in g else Color.WHITE,
		"cor_mochila": g.cor_mochila if "cor_mochila" in g else Color.WHITE,
		"textura_corpo": g.textura_corpo if "textura_corpo" in g else "",
		"textura_cabelo": g.textura_cabelo if "textura_cabelo" in g else "",
		"textura_blusa": g.textura_blusa if "textura_blusa" in g else "",
		"textura_calca": g.textura_calca if "textura_calca" in g else "",
		"textura_sapato": g.textura_sapato if "textura_sapato" in g else "",
		"textura_mochila": g.textura_mochila if "textura_mochila" in g else "",
		"tem_calca": tem_calca
	}
	aplicar_configuracao(config)


func aplicar_configuracao(c: Dictionary) -> void:
	_sexo = c.get("sexo", "masculino")
	
	# Configura AnimatedSpriteCorpo com os frames correspondentes
	if is_instance_valid(anim_corpo):
		anim_corpo.sprite_frames = FRAMES_MENINA if _sexo == "feminina" else FRAMES_MENINO
		var cor_pele: Color = c.get("cor_pele", Color(0.92, 0.76, 0.62))
		anim_corpo.modulate = cor_pele.lerp(Color.WHITE, 0.35)
		anim_corpo.visible = true

	# 1. Mochila (z=0, atrás de tudo)
	_atualizar_camada(spr_mochila, c.get("textura_mochila", ""), Color.WHITE)
	
	# 2. Corpo estático (se usado como fallback)
	if is_instance_valid(spr_corpo):
		var tem_calca: bool = c.get("tem_calca", false)
		var tex_corpo: String = ""
		if tem_calca:
			tex_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino_calca.png" if _sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino_calca.png"
		else:
			tex_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino.png" if _sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
		var cor_pele_val: Color = c.get("cor_pele", Color(0.92, 0.76, 0.62))
		_atualizar_camada(spr_corpo, tex_corpo, cor_pele_val.lerp(Color.WHITE, 0.35))
	
	# 3. Calça / Short (z=3)
	_atualizar_camada(spr_calca, c.get("textura_calca", ""), Color.WHITE)
	
	# 4. Sapato (z=4)
	_atualizar_camada(spr_sapato, c.get("textura_sapato", ""), Color.WHITE)
	
	# 5. Blusa (z=5)
	_atualizar_camada(spr_blusa, c.get("textura_blusa", ""), Color.WHITE)
	
	# 6. Cabelo (z=6)
	var tex_cabelo: String = c.get("textura_cabelo", "")
	if tex_cabelo == "" or not ResourceLoader.exists(tex_cabelo):
		var estilo: String = c.get("estilo_cabelo", "curto")
		tex_cabelo = "res://assets/Personagens/customizacao/CANVAS_180x360/cabelos/liso_longo.png" if estilo == "longo" else "res://assets/Personagens/customizacao/CANVAS_180x360/cabelos/curto_desfiado.png"
	var cor_cabelo: Color = c.get("cor_cabelo", Color(0.22, 0.14, 0.08))
	_atualizar_camada(spr_cabelo_frente, tex_cabelo, cor_cabelo)


func _atualizar_camada(sprite: Sprite2D, path: String, cor_modulate: Color) -> void:
	if not is_instance_valid(sprite):
		return
	if path != "" and ResourceLoader.exists(path):
		sprite.texture = load(path)
		sprite.modulate = cor_modulate
		sprite.visible = true
	else:
		sprite.texture = null
		sprite.visible = false


func tocar_animacao(nome: String) -> void:
	_animacao_atual = nome
	if is_instance_valid(anim_corpo) and anim_corpo.sprite_frames != null:
		if anim_corpo.sprite_frames.has_animation(nome):
			if anim_corpo.animation != nome or not anim_corpo.is_playing():
				anim_corpo.play(nome)


func definir_animacao_andando(andando: bool) -> void:
	if andando:
		tocar_animacao("walk_side")
	else:
		tocar_animacao("idle")


func definir_espelhamento(olhando_esquerda: bool) -> void:
	_olhando_esquerda = olhando_esquerda
	if is_instance_valid(anim_corpo):
		anim_corpo.flip_h = olhando_esquerda
	scale.x = -abs(scale.x) if olhando_esquerda else abs(scale.x)
