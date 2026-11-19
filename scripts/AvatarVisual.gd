extends Node2D
class_name AvatarVisual
## Componente visual unificado do avatar do jogador (180x360).
## Usado tanto no Preview da criação quanto no Player do Museu e fases do jogo.

@onready var spr_mochila: Sprite2D = $Mochila as Sprite2D
@onready var spr_cabelo_tras: Sprite2D = $CabeloTras as Sprite2D
@onready var spr_corpo: Sprite2D = $Corpo as Sprite2D
@onready var spr_calca: Sprite2D = $Calca as Sprite2D
@onready var spr_sapato: Sprite2D = $Sapato as Sprite2D
@onready var spr_blusa: Sprite2D = $Blusa as Sprite2D
@onready var spr_cabelo_frente: Sprite2D = $CabeloFrente as Sprite2D

var anim_walking: bool = false
var _anim_time: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	_base_y = position.y
	carregar_do_global()


func _process(delta: float) -> void:
	if anim_walking:
		_anim_time += delta * 12.0
		# Suave balanço natural ao caminhar
		position.y = _base_y + sin(_anim_time) * 3.0
		rotation = sin(_anim_time * 0.5) * 0.04
	else:
		_anim_time = 0.0
		position.y = _base_y
		rotation = 0.0


func definir_animacao_andando(andando: bool) -> void:
	anim_walking = andando


func definir_espelhamento(olhando_esquerda: bool) -> void:
	scale.x = -abs(scale.x) if olhando_esquerda else abs(scale.x)


func carregar_do_global() -> void:
	if not Engine.has_singleton("Global") and not has_node("/root/Global"):
		return
	var g: Node = get_node("/root/Global")
	
	var config: Dictionary = {
		"sexo": g.sexo if "sexo" in g else "masculino",
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
		"textura_mochila": g.textura_mochila if "textura_mochila" in g else ""
	}
	aplicar_configuracao(config)


func aplicar_configuracao(c: Dictionary) -> void:
	# 1. Mochila
	_atualizar_camada(spr_mochila, c.get("textura_mochila", ""), Color.WHITE)
	
	# 2. Corpo Base / Pele
	var tex_corpo: String = c.get("textura_corpo", "")
	if tex_corpo == "" or not ResourceLoader.exists(tex_corpo):
		var sexo: String = c.get("sexo", "masculino")
		tex_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino.png" if sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
	var cor_pele: Color = c.get("cor_pele", Color(0.92, 0.76, 0.62))
	_atualizar_camada(spr_corpo, tex_corpo, cor_pele.lerp(Color.WHITE, 0.35))
	
	# 3. Calça / Short
	_atualizar_camada(spr_calca, c.get("textura_calca", ""), Color.WHITE)
	
	# 4. Sapato
	_atualizar_camada(spr_sapato, c.get("textura_sapato", ""), Color.WHITE)
	
	# 5. Blusa
	_atualizar_camada(spr_blusa, c.get("textura_blusa", ""), Color.WHITE)
	
	# 6. Cabelo
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
