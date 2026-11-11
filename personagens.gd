extends Control
## Controlador da tela de customização do personagem
## Permite personalizar: Nome, Sexo, Roupa, Cabelo, Cor de Pele, Cor do Cabelo, Estilo de Cabelo (Longo/Curto), Cor do Sapato, Cor da Mochila.

const CENA_MUSEU: String = "res://cenas/museu_fase.tscn"
const CENA_TITLE_SCREEN: String = "res://cenas/title_screen.tscn"
const SOM_NAVEGAR: AudioStream = preload("res://audios/ui/menu_navegar.ogg")
const SOM_CONFIRMAR: AudioStream = preload("res://audios/ui/menu_confirmar.ogg")
const SOM_VOLTAR: AudioStream = preload("res://audios/ui/menu_voltar.ogg")

const PALETA_PELE: Array[Color] = [
	Color(0.96, 0.82, 0.72), # Pele clara 1
	Color(0.92, 0.75, 0.62), # Pele clara 2
	Color(0.82, 0.62, 0.46), # Pele morena clara
	Color(0.68, 0.48, 0.33), # Pele morena
	Color(0.48, 0.32, 0.22), # Pele negra 1
	Color(0.32, 0.20, 0.14)  # Pele negra 2
]

const PALETA_CABELO: Array[Color] = [
	Color(0.12, 0.08, 0.06), # Preto
	Color(0.35, 0.22, 0.12), # Castanho escuro
	Color(0.55, 0.36, 0.20), # Castanho claro
	Color(0.85, 0.65, 0.35), # Loiro
	Color(0.72, 0.28, 0.18), # Ruivo
	Color(0.80, 0.80, 0.85)  # Grisalho / Prata
]

const PALETA_ROUPA: Array[Color] = [
	Color(0.24, 0.45, 0.75), # Azul sertanejo
	Color(0.82, 0.32, 0.25), # Vermelho argila
	Color(0.32, 0.60, 0.38), # Verde carnaúba
	Color(0.88, 0.72, 0.28), # Amarelo sol
	Color(0.85, 0.85, 0.85), # Branco algodão
	Color(0.30, 0.22, 0.28)  # Roxo crepúsculo
]

const PALETA_SAPATO: Array[Color] = [
	Color(0.25, 0.16, 0.10), # Couro escuro
	Color(0.48, 0.32, 0.20), # Couro natural
	Color(0.15, 0.15, 0.16), # Preto
	Color(0.70, 0.60, 0.48), # Areia
	Color(0.75, 0.30, 0.25)  # Bordô
]

const PALETA_MOCHILA: Array[Color] = [
	Color(0.65, 0.42, 0.22), # Couro legítimo
	Color(0.32, 0.48, 0.35), # Lona verde militar
	Color(0.25, 0.38, 0.58), # Lona azul marinho
	Color(0.75, 0.55, 0.25), # Mostarda
	Color(0.35, 0.28, 0.38)  # Berinjela
]

var _idx_pele: int = 1
var _idx_cabelo_cor: int = 1
var _idx_roupa: int = 0
var _idx_sapato: int = 0
var _idx_mochila: int = 0
var _estilo_cabelo: String = "curto" # "curto" ou "longo"
var _sexo: String = "masculino" # "masculino" ou "feminina"

var _player_sfx: AudioStreamPlayer

@onready var line_edit_nome: LineEdit = find_child("LineEditNome", true, false) as LineEdit
@onready var btn_sexo_masc: Button = find_child("BtnSexoMasc", true, false) as Button
@onready var btn_sexo_fem: Button = find_child("BtnSexoFem", true, false) as Button
@onready var btn_cabelo_curto: Button = find_child("BtnCabeloCurto", true, false) as Button
@onready var btn_cabelo_longo: Button = find_child("BtnCabeloLongo", true, false) as Button

# Indicadores de cor
@onready var color_rect_pele: ColorRect = find_child("PreviewCorPele", true, false) as ColorRect
@onready var color_rect_cabelo: ColorRect = find_child("PreviewCorCabelo", true, false) as ColorRect
@onready var color_rect_roupa: ColorRect = find_child("PreviewCorRoupa", true, false) as ColorRect
@onready var color_rect_sapato: ColorRect = find_child("PreviewCorSapato", true, false) as ColorRect
@onready var color_rect_mochila: ColorRect = find_child("PreviewCorMochila", true, false) as ColorRect

# Preview do boneco
@onready var sprite_preview_base: TextureRect = find_child("SpritePreviewBase", true, false) as TextureRect
@onready var sprite_preview_cabelo: TextureRect = find_child("SpritePreviewCabelo", true, false) as TextureRect
@onready var label_resumo_personagem: Label = find_child("LabelResumoPersonagem", true, false) as Label

# Botões de navegação
@onready var btn_concluido: Button = find_child("BotaoConcluido", true, false) as Button
@onready var btn_voltar: Button = find_child("BotaoVoltar", true, false) as Button


func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos" if AudioServer.get_bus_index("efeitos") != -1 else &"Master"
	add_child(_player_sfx)

	_configurar_seletores()
	_atualizar_interface()


func _tocar_sfx(stream: AudioStream) -> void:
	if is_instance_valid(_player_sfx) and stream != null:
		_player_sfx.stream = stream
		_player_sfx.pitch_scale = randf_range(0.96, 1.04)
		_player_sfx.play()


func _configurar_seletores() -> void:
	if is_instance_valid(btn_sexo_masc):
		btn_sexo_masc.pressed.connect(func() -> void:
			_sexo = "masculino"
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)
	if is_instance_valid(btn_sexo_fem):
		btn_sexo_fem.pressed.connect(func() -> void:
			_sexo = "feminina"
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)

	if is_instance_valid(btn_cabelo_curto):
		btn_cabelo_curto.pressed.connect(func() -> void:
			_estilo_cabelo = "curto"
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)
	if is_instance_valid(btn_cabelo_longo):
		btn_cabelo_longo.pressed.connect(func() -> void:
			_estilo_cabelo = "longo"
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)

	_vincular_seletor("Pele", PALETA_PELE.size(), func(delta: int) -> void:
		_idx_pele = posmod(_idx_pele + delta, PALETA_PELE.size())
	)
	_vincular_seletor("Cabelo", PALETA_CABELO.size(), func(delta: int) -> void:
		_idx_cabelo_cor = posmod(_idx_cabelo_cor + delta, PALETA_CABELO.size())
	)
	_vincular_seletor("Roupa", PALETA_ROUPA.size(), func(delta: int) -> void:
		_idx_roupa = posmod(_idx_roupa + delta, PALETA_ROUPA.size())
	)
	_vincular_seletor("Sapato", PALETA_SAPATO.size(), func(delta: int) -> void:
		_idx_sapato = posmod(_idx_sapato + delta, PALETA_SAPATO.size())
	)
	_vincular_seletor("Mochila", PALETA_MOCHILA.size(), func(delta: int) -> void:
		_idx_mochila = posmod(_idx_mochila + delta, PALETA_MOCHILA.size())
	)

	if is_instance_valid(btn_concluido):
		btn_concluido.pressed.connect(_on_concluido_pressed)
	if is_instance_valid(btn_voltar):
		btn_voltar.pressed.connect(_on_voltar_pressed)


func _vincular_seletor(categoria: String, _max_items: int, callback: Callable) -> void:
	var btn_prev: Button = find_child("BtnPrev" + categoria, true, false) as Button
	var btn_next: Button = find_child("BtnNext" + categoria, true, false) as Button
	if is_instance_valid(btn_prev):
		btn_prev.pressed.connect(func() -> void:
			callback.call(-1)
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)
	if is_instance_valid(btn_next):
		btn_next.pressed.connect(func() -> void:
			callback.call(1)
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)


func _atualizar_interface() -> void:
	# Atualiza Cores de Pré-visualização nos botões
	if is_instance_valid(color_rect_pele):
		color_rect_pele.color = PALETA_PELE[_idx_pele]
	if is_instance_valid(color_rect_cabelo):
		color_rect_cabelo.color = PALETA_CABELO[_idx_cabelo_cor]
	if is_instance_valid(color_rect_roupa):
		color_rect_roupa.color = PALETA_ROUPA[_idx_roupa]
	if is_instance_valid(color_rect_sapato):
		color_rect_sapato.color = PALETA_SAPATO[_idx_sapato]
	if is_instance_valid(color_rect_mochila):
		color_rect_mochila.color = PALETA_MOCHILA[_idx_mochila]

	# Atualiza Destaque dos Botões de Seleção
	if is_instance_valid(btn_sexo_masc):
		btn_sexo_masc.modulate = Color(1.2, 1.15, 0.8) if _sexo == "masculino" else Color(0.7, 0.7, 0.7)
	if is_instance_valid(btn_sexo_fem):
		btn_sexo_fem.modulate = Color(1.2, 1.15, 0.8) if _sexo == "feminina" else Color(0.7, 0.7, 0.7)

	if is_instance_valid(btn_cabelo_curto):
		btn_cabelo_curto.modulate = Color(1.2, 1.15, 0.8) if _estilo_cabelo == "curto" else Color(0.7, 0.7, 0.7)
	if is_instance_valid(btn_cabelo_longo):
		btn_cabelo_longo.modulate = Color(1.2, 1.15, 0.8) if _estilo_cabelo == "longo" else Color(0.7, 0.7, 0.7)

	# Atualiza o Sprite do Personagem
	if is_instance_valid(sprite_preview_base):
		var caminho_base: String = "res://assets/Personagens/masculino_2d/idle/idle_00.png"
		if _sexo == "feminina":
			caminho_base = "res://assets/Personagens/feminina_2d/idle/idle_00.png"
		if ResourceLoader.exists(caminho_base):
			sprite_preview_base.texture = load(caminho_base)
		# Tinta sutil na roupa e pele da pré-visualização
		sprite_preview_base.self_modulate = PALETA_PELE[_idx_pele].lerp(Color.WHITE, 0.4)

	if is_instance_valid(label_resumo_personagem):
		var nome_txt: String = line_edit_nome.text.strip_edges() if is_instance_valid(line_edit_nome) and line_edit_nome.text.strip_edges() != "" else "Bento"
		label_resumo_personagem.text = "%s  •  %s  •  Cabelo %s" % [
			nome_txt,
			"Menino" if _sexo == "masculino" else "Menina",
			"Curto" if _estilo_cabelo == "curto" else "Longo"
		]


func _salvar_no_global() -> void:
	if not Engine.has_singleton("Global") and not has_node("/root/Global"):
		return
	var g: Node = get_node("/root/Global")
	var nome_final: String = line_edit_nome.text.strip_edges() if is_instance_valid(line_edit_nome) and line_edit_nome.text.strip_edges() != "" else "Bento"
	g.nome_personagem = nome_final
	g.sexo = _sexo
	g.estilo_cabelo = _estilo_cabelo
	g.cor_pele = PALETA_PELE[_idx_pele]
	g.cor_cabelo = PALETA_CABELO[_idx_cabelo_cor]
	g.cor_roupa = PALETA_ROUPA[_idx_roupa]
	g.cor_sapato = PALETA_SAPATO[_idx_sapato]
	g.cor_mochila = PALETA_MOCHILA[_idx_mochila]
	g.fase_atual = "museu_introducao"


func _on_concluido_pressed() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	_salvar_no_global()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.chain().tween_callback(func() -> void:
		get_tree().change_scene_to_file(CENA_MUSEU)
	)


func _on_voltar_pressed() -> void:
	_tocar_sfx(SOM_VOLTAR)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(func() -> void:
		get_tree().change_scene_to_file(CENA_TITLE_SCREEN)
	)
