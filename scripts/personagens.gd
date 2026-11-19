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
	Color(0.85, 0.85, 0.88)  # Grisalho / Prata
]

const PALETA_BLUSA: Array[Color] = [
	Color(0.24, 0.45, 0.75), # Azul
	Color(0.88, 0.72, 0.28), # Amarelo
	Color(0.82, 0.32, 0.25), # Vermelho
	Color(0.32, 0.60, 0.38), # Verde
	Color(0.85, 0.85, 0.85), # Branco
	Color(0.45, 0.45, 0.48), # Cinza
	Color(0.18, 0.18, 0.20), # Preto
	Color(0.88, 0.45, 0.60)  # Rosa
]

const LISTA_BLUSAS: Array[String] = [
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_azul.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_amarela.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_vermelha.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_verde.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_branca.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_cinza.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_preta.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/roupas/camiseta_rosa.png"
]

const PALETA_CALCA: Array[Color] = [
	Color(0.20, 0.35, 0.55), # Jeans Azul
	Color(0.15, 0.20, 0.35), # Azul Marinho
	Color(0.75, 0.65, 0.50), # Bege
	Color(0.85, 0.85, 0.88), # Branco
	Color(0.30, 0.30, 0.35), # Grafite
	Color(0.45, 0.25, 0.18), # Marrom
	Color(0.18, 0.18, 0.20), # Preto
	Color(0.30, 0.50, 0.30), # Verde
	Color(0.55, 0.20, 0.25)  # Vermelha
]

const LISTA_CALCAS: Array[String] = [
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_jeans_azul.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_azul_marinho.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_bege.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_branca.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_grafite.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_marrom.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_preta.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_verde.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/calca_vermelha.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_jeans_azul.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_bege.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_cinza.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_jeans.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_jeans_claro.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_preta.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_verde.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/calcas_bermudas/bermuda_vermelha.png"
]

const PALETA_SAPATO: Array[Color] = [
	Color(0.15, 0.15, 0.16), # Preto
	Color(0.85, 0.85, 0.85), # Branco
	Color(0.20, 0.32, 0.65), # Azul Marinho
	Color(0.25, 0.50, 0.80), # Azul
	Color(0.82, 0.30, 0.25), # Vermelho
	Color(0.88, 0.72, 0.25), # Amarelo
	Color(0.32, 0.60, 0.38), # Verde
	Color(0.85, 0.45, 0.60), # Rosa
	Color(0.50, 0.25, 0.60)  # Roxo
]

const LISTA_SAPATOS: Array[String] = [
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_preto.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_branco.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_azul_marinho.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_azul.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_vermelho.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_amarelo.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_verde.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_rosa.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_roxo.png"
]

const PALETA_MOCHILA: Array[Color] = [
	Color(0.20, 0.32, 0.65), # Azul Marinho
	Color(0.35, 0.60, 0.85), # Azul Claro
	Color(0.25, 0.25, 0.26), # Grafite
	Color(0.85, 0.85, 0.85), # Branca
	Color(0.88, 0.72, 0.25), # Amarela
	Color(0.82, 0.30, 0.25), # Vermelha
	Color(0.32, 0.60, 0.38), # Verde
	Color(0.85, 0.45, 0.60)  # Rosa
]

const LISTA_MOCHILAS: Array[String] = [
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_azul_marinho.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_azul_claro.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_grafite.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_branca.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_amarela.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_vermelha.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_verde.png",
	"res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_rosa.png"
]

var _idx_pele: int = 1
var _idx_cabelo_cor: int = 1
var _idx_blusa: int = 0 # Inicial padrão selecionada (não começa pelado)
var _idx_calca: int = 0 # Inicial padrão selecionada (não começa pelado)
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
@onready var color_rect_blusa: ColorRect = (find_child("PreviewCorBlusa", true, false) as ColorRect) if find_child("PreviewCorBlusa", true, false) != null else find_child("PreviewCorRoupa", true, false) as ColorRect
@onready var color_rect_calca: ColorRect = find_child("PreviewCorCalca", true, false) as ColorRect
@onready var color_rect_sapato: ColorRect = find_child("PreviewCorSapato", true, false) as ColorRect
@onready var color_rect_mochila: ColorRect = find_child("PreviewCorMochila", true, false) as ColorRect

# Preview do boneco em camadas
@onready var sprite_preview_mochila: TextureRect = find_child("SpritePreviewMochila", true, false) as TextureRect
@onready var sprite_preview_base: TextureRect = find_child("SpritePreviewBase", true, false) as TextureRect
@onready var sprite_preview_calca: TextureRect = find_child("SpritePreviewCalca", true, false) as TextureRect
@onready var sprite_preview_sapato: TextureRect = find_child("SpritePreviewSapato", true, false) as TextureRect
@onready var sprite_preview_blusa: TextureRect = (find_child("SpritePreviewBlusa", true, false) as TextureRect) if find_child("SpritePreviewBlusa", true, false) != null else find_child("SpritePreviewRoupa", true, false) as TextureRect
@onready var sprite_preview_cabelo: TextureRect = find_child("SpritePreviewCabelo", true, false) as TextureRect
@onready var label_resumo_personagem: Label = find_child("LabelResumoPersonagem", true, false) as Label

# Botões de navegação
@onready var btn_concluido: Button = find_child("BotaoConcluido", true, false) as Button
@onready var btn_voltar: Button = find_child("BotaoVoltar", true, false) as Button


func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos" if AudioServer.get_bus_index("efeitos") != -1 else &"Master"
	add_child(_player_sfx)

	if is_instance_valid(line_edit_nome):
		line_edit_nome.text_changed.connect(func(_novo_texto: String) -> void:
			_atualizar_resumo()
		)

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
	_vincular_seletor("Blusa", LISTA_BLUSAS.size(), func(delta: int) -> void:
		if _idx_blusa == -1:
			_idx_blusa = 0 if delta > 0 else (LISTA_BLUSAS.size() - 1)
		else:
			_idx_blusa = posmod(_idx_blusa + delta, LISTA_BLUSAS.size())
	)
	_vincular_seletor("Roupa", LISTA_BLUSAS.size(), func(delta: int) -> void:
		if _idx_blusa == -1:
			_idx_blusa = 0 if delta > 0 else (LISTA_BLUSAS.size() - 1)
		else:
			_idx_blusa = posmod(_idx_blusa + delta, LISTA_BLUSAS.size())
	)
	_vincular_seletor("Calca", LISTA_CALCAS.size(), func(delta: int) -> void:
		if _idx_calca == -1:
			_idx_calca = 0 if delta > 0 else (LISTA_CALCAS.size() - 1)
		else:
			_idx_calca = posmod(_idx_calca + delta, LISTA_CALCAS.size())
	)
	_vincular_seletor("Sapato", LISTA_SAPATOS.size(), func(delta: int) -> void:
		_idx_sapato = posmod(_idx_sapato + delta, LISTA_SAPATOS.size())
	)
	_vincular_seletor("Mochila", LISTA_MOCHILAS.size(), func(delta: int) -> void:
		_idx_mochila = posmod(_idx_mochila + delta, LISTA_MOCHILAS.size())
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
	# Atualiza Cores de Pré-visualização nos cartões de seleção
	if is_instance_valid(color_rect_pele):
		color_rect_pele.color = PALETA_PELE[_idx_pele]
	if is_instance_valid(color_rect_cabelo):
		color_rect_cabelo.color = PALETA_CABELO[_idx_cabelo_cor]

	if is_instance_valid(color_rect_blusa):
		if _idx_blusa >= 0:
			color_rect_blusa.color = PALETA_BLUSA[_idx_blusa % PALETA_BLUSA.size()]
		else:
			color_rect_blusa.color = Color(0.35, 0.35, 0.35, 0.5)

	if is_instance_valid(color_rect_calca):
		if _idx_calca >= 0:
			color_rect_calca.color = PALETA_CALCA[_idx_calca % PALETA_CALCA.size()]
		else:
			color_rect_calca.color = Color(0.35, 0.35, 0.35, 0.5)

	if is_instance_valid(color_rect_sapato):
		color_rect_sapato.color = PALETA_SAPATO[_idx_sapato % PALETA_SAPATO.size()]
	if is_instance_valid(color_rect_mochila):
		color_rect_mochila.color = PALETA_MOCHILA[_idx_mochila % PALETA_MOCHILA.size()]

	# Atualiza Destaque dos Botões de Seleção
	if is_instance_valid(btn_sexo_masc):
		btn_sexo_masc.modulate = Color(1.2, 1.15, 0.8) if _sexo == "masculino" else Color(0.7, 0.7, 0.7)
	if is_instance_valid(btn_sexo_fem):
		btn_sexo_fem.modulate = Color(1.2, 1.15, 0.8) if _sexo == "feminina" else Color(0.7, 0.7, 0.7)

	if is_instance_valid(btn_cabelo_curto):
		btn_cabelo_curto.modulate = Color(1.2, 1.15, 0.8) if _estilo_cabelo == "curto" else Color(0.7, 0.7, 0.7)
	if is_instance_valid(btn_cabelo_longo):
		btn_cabelo_longo.modulate = Color(1.2, 1.15, 0.8) if _estilo_cabelo == "longo" else Color(0.7, 0.7, 0.7)

	# 1. Camada Mochila (Z=0, atrás de tudo)
	if is_instance_valid(sprite_preview_mochila):
		var p_mochila: String = LISTA_MOCHILAS[_idx_mochila % LISTA_MOCHILAS.size()]
		if ResourceLoader.exists(p_mochila):
			sprite_preview_mochila.texture = load(p_mochila)

	# 2. Camada Corpo Base
	if is_instance_valid(sprite_preview_base):
		var p_corpo: String = ""
		if _idx_calca >= 0:
			p_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino_calca.png" if _sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino_calca.png"
		else:
			p_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino.png" if _sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
		if ResourceLoader.exists(p_corpo):
			sprite_preview_base.texture = load(p_corpo)
		sprite_preview_base.modulate = PALETA_PELE[_idx_pele].lerp(Color.WHITE, 0.35)

	# 3. Camada Calça / Short (aparece apenas quando selecionado)
	if is_instance_valid(sprite_preview_calca):
		if _idx_calca >= 0:
			var p_calca: String = LISTA_CALCAS[_idx_calca % LISTA_CALCAS.size()]
			if ResourceLoader.exists(p_calca):
				sprite_preview_calca.texture = load(p_calca)
				sprite_preview_calca.visible = true
			else:
				sprite_preview_calca.visible = false
		else:
			sprite_preview_calca.visible = false
			sprite_preview_calca.texture = null

	# 4. Camada Sapato (visível por cima da calça e pés)
	if is_instance_valid(sprite_preview_sapato):
		var p_sapato: String = LISTA_SAPATOS[_idx_sapato % LISTA_SAPATOS.size()]
		if ResourceLoader.exists(p_sapato):
			sprite_preview_sapato.texture = load(p_sapato)
			sprite_preview_sapato.visible = true

	# 5. Camada Blusa (aparece apenas quando selecionado)
	if is_instance_valid(sprite_preview_blusa):
		if _idx_blusa >= 0:
			var p_blusa: String = LISTA_BLUSAS[_idx_blusa % LISTA_BLUSAS.size()]
			if ResourceLoader.exists(p_blusa):
				sprite_preview_blusa.texture = load(p_blusa)
				sprite_preview_blusa.visible = true
			else:
				sprite_preview_blusa.visible = false
		else:
			sprite_preview_blusa.visible = false
			sprite_preview_blusa.texture = null

	# 6. Camada Cabelo
	if is_instance_valid(sprite_preview_cabelo):
		var nome_cab: String = "curto_desfiado.png" if _estilo_cabelo == "curto" else "liso_longo.png"
		var p_cabelo: String = "res://assets/Personagens/customizacao/CANVAS_180x360/cabelos/" + nome_cab
		if ResourceLoader.exists(p_cabelo):
			sprite_preview_cabelo.texture = load(p_cabelo)
		sprite_preview_cabelo.modulate = PALETA_CABELO[_idx_cabelo_cor]

	_atualizar_resumo()


func _atualizar_resumo() -> void:
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
	
	g.idx_pele = _idx_pele
	g.idx_cabelo_cor = _idx_cabelo_cor
	g.idx_blusa = _idx_blusa
	g.idx_calca = _idx_calca
	g.idx_sapato = _idx_sapato
	g.idx_mochila = _idx_mochila

	g.cor_pele = PALETA_PELE[_idx_pele]
	g.cor_cabelo = PALETA_CABELO[_idx_cabelo_cor]

	var cor_blusa_final: Color = PALETA_BLUSA[_idx_blusa % PALETA_BLUSA.size()] if _idx_blusa >= 0 else Color(0.24, 0.45, 0.72, 1.0)
	var cor_calca_final: Color = PALETA_CALCA[_idx_calca % PALETA_CALCA.size()] if _idx_calca >= 0 else Color(0.2, 0.35, 0.55, 1.0)
	g.cor_blusa = cor_blusa_final
	g.cor_calca = cor_calca_final
	g.cor_roupa = cor_blusa_final # Compatibilidade com telas antigas
	g.cor_sapato = PALETA_SAPATO[_idx_sapato % PALETA_SAPATO.size()]
	g.cor_mochila = PALETA_MOCHILA[_idx_mochila % PALETA_MOCHILA.size()]

	# Texturas selecionadas
	g.textura_corpo = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_feminino.png" if _sexo == "feminina" else "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
	var nome_cab: String = "curto_desfiado.png" if _estilo_cabelo == "curto" else "liso_longo.png"
	g.textura_cabelo = "res://assets/Personagens/customizacao/CANVAS_180x360/cabelos/" + nome_cab
	g.textura_blusa = LISTA_BLUSAS[_idx_blusa % LISTA_BLUSAS.size()] if _idx_blusa >= 0 else ""
	g.textura_calca = LISTA_CALCAS[_idx_calca % LISTA_CALCAS.size()] if _idx_calca >= 0 else ""
	g.textura_sapato = LISTA_SAPATOS[_idx_sapato % LISTA_SAPATOS.size()]
	g.textura_mochila = LISTA_MOCHILAS[_idx_mochila % LISTA_MOCHILAS.size()]

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
