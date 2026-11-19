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
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer

var _olhando_esquerda: bool = false
var _andando: bool = false


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
	# 1. Mochila (z=0, atrás de tudo)
	_atualizar_camada(spr_mochila, c.get("textura_mochila", ""), Color.WHITE)
	
	# 2. Corpo Base / Pele (z=2)
	# Se estiver de calça/bermuda comprida, usa a textura mascarada que elimina qualquer vazamento atrás das pernas
	var tem_calca: bool = c.get("tem_calca", false)
	var sexo: String = c.get("sexo", "masculino")
	var tex_corpo: String = ""
	if tem_calca:
		tex_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino_calca.png" if sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino_calca.png"
	else:
		tex_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino.png" if sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
	
	var cor_pele: Color = c.get("cor_pele", Color(0.92, 0.76, 0.62))
	_atualizar_camada(spr_corpo, tex_corpo, cor_pele.lerp(Color.WHITE, 0.35))
	
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
	if is_instance_valid(anim_player) and anim_player.has_animation(nome):
		if anim_player.current_animation != nome:
			anim_player.play(nome)


func definir_animacao_andando(andando: bool) -> void:
	if _andando == andando:
		return
	_andando = andando
	if _andando:
		tocar_animacao("walk")
	else:
		tocar_animacao("idle")


func definir_espelhamento(olhando_esquerda: bool) -> void:
	_olhando_esquerda = olhando_esquerda
	scale.x = -abs(scale.x) if olhando_esquerda else abs(scale.x)
