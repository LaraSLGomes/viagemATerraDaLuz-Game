extends Control
## Controlador da tela de customização do personagem
## Utiliza o componente unificado AvatarVisual com Shader de Palette Swap
## e catálogo CompositeSprites para troca em tempo real.

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
	Color(0.85, 0.15, 0.15), # Vermelho Vivo
	Color(0.24, 0.45, 0.75), # Azul
	Color(0.88, 0.72, 0.28), # Amarelo
	Color(0.32, 0.60, 0.38), # Verde
	Color(0.85, 0.85, 0.85), # Branco
	Color(0.45, 0.45, 0.48), # Cinza
	Color(0.18, 0.18, 0.20), # Preto
	Color(0.88, 0.45, 0.60)  # Rosa
]

const PALETA_CALCA: Array[Color] = [
	Color(0.15, 0.35, 0.75), # Azul Vivo
	Color(0.15, 0.20, 0.35), # Azul Marinho
	Color(0.75, 0.65, 0.50), # Bege
	Color(0.85, 0.85, 0.88), # Branco
	Color(0.30, 0.30, 0.35), # Grafite
	Color(0.45, 0.25, 0.18), # Marrom
	Color(0.18, 0.18, 0.20), # Preto
	Color(0.30, 0.50, 0.30), # Verde
	Color(0.55, 0.20, 0.25)  # Vermelha
]

const PALETA_SAPATO: Array[Color] = [
	Color(0.95, 0.85, 0.20), # Amarelo Vivo
	Color(0.15, 0.15, 0.16), # Preto
	Color(0.85, 0.85, 0.85), # Branco
	Color(0.20, 0.32, 0.65), # Azul Marinho
	Color(0.25, 0.50, 0.80), # Azul
	Color(0.82, 0.30, 0.25), # Vermelho
	Color(0.32, 0.60, 0.38), # Verde
	Color(0.85, 0.45, 0.60), # Rosa
	Color(0.50, 0.25, 0.60)  # Roxo
]

const PALETA_MOCHILA: Array[Color] = [
	Color(0.20, 0.70, 0.25), # Verde Vivo
	Color(0.20, 0.32, 0.65), # Azul Marinho
	Color(0.35, 0.60, 0.85), # Azul Claro
	Color(0.25, 0.25, 0.26), # Grafite
	Color(0.85, 0.85, 0.85), # Branca
	Color(0.88, 0.72, 0.25), # Amarela
	Color(0.82, 0.30, 0.25), # Vermelha
	Color(0.85, 0.45, 0.60)  # Rosa
]

const NOMES_ESTILOS_CABELO: Array[String] = [
	"Curto",
	"Longo",
	"Ondulado",
	"Crespo Baixo",
	"Crespo Volumoso"
]

const CHAVES_ESTILOS_CABELO: Array[String] = [
	"curto",
	"longo",
	"ondulado",
	"crespo_baixo",
	"crespo_volumoso"
]

var _idx_pele: int = 1
var _idx_cabelo_cor: int = 1
var _idx_cabelo_estilo: int = 0
var _idx_blusa: int = 0
var _idx_calca: int = 0
var _idx_sapato: int = 0
var _idx_mochila: int = 0
var _sexo: String = "masculino"

var _player_sfx: AudioStreamPlayer

@onready var line_edit_nome: LineEdit = find_child("LineEditNome", true, false) as LineEdit
@onready var btn_sexo_masc: Button = find_child("BtnSexoMasc", true, false) as Button
@onready var btn_sexo_fem: Button = find_child("BtnSexoFem", true, false) as Button
@onready var label_valor_cabelo_estilo: Label = find_child("LabelValorCabeloEstilo", true, false) as Label
@onready var btn_prev_cabelo_estilo: Button = find_child("BtnPrevCabeloEstilo", true, false) as Button
@onready var btn_next_cabelo_estilo: Button = find_child("BtnNextCabeloEstilo", true, false) as Button

# Indicadores de cor
@onready var color_rect_pele: ColorRect = find_child("PreviewCorPele", true, false) as ColorRect
@onready var color_rect_cabelo: ColorRect = find_child("PreviewCorCabelo", true, false) as ColorRect
@onready var color_rect_blusa: ColorRect = (find_child("PreviewCorBlusa", true, false) as ColorRect) if find_child("PreviewCorBlusa", true, false) != null else find_child("PreviewCorRoupa", true, false) as ColorRect
@onready var color_rect_calca: ColorRect = find_child("PreviewCorCalca", true, false) as ColorRect
@onready var color_rect_sapato: ColorRect = find_child("PreviewCorSapato", true, false) as ColorRect
@onready var color_rect_mochila: ColorRect = find_child("PreviewCorMochila", true, false) as ColorRect

# Preview unificado do Avatar
@onready var avatar_preview: Node2D = find_child("AvatarVisualPreview", true, false) as Node2D
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
	
	# Inicia caminhada lenta de frente no preview para dar vida ao personagem
	if is_instance_valid(avatar_preview) and avatar_preview.has_method("tocar_animacao"):
		avatar_preview.tocar_animacao("walk_front")


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

	if is_instance_valid(btn_prev_cabelo_estilo):
		btn_prev_cabelo_estilo.pressed.connect(func() -> void:
			_idx_cabelo_estilo = posmod(_idx_cabelo_estilo - 1, CHAVES_ESTILOS_CABELO.size())
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)
	if is_instance_valid(btn_next_cabelo_estilo):
		btn_next_cabelo_estilo.pressed.connect(func() -> void:
			_idx_cabelo_estilo = posmod(_idx_cabelo_estilo + 1, CHAVES_ESTILOS_CABELO.size())
			_tocar_sfx(SOM_NAVEGAR)
			_atualizar_interface()
		)

	_vincular_seletor("Pele", PALETA_PELE.size(), func(delta: int) -> void:
		_idx_pele = posmod(_idx_pele + delta, PALETA_PELE.size())
	)
	_vincular_seletor("Cabelo", PALETA_CABELO.size(), func(delta: int) -> void:
		_idx_cabelo_cor = posmod(_idx_cabelo_cor + delta, PALETA_CABELO.size())
	)
	_vincular_seletor("Blusa", PALETA_BLUSA.size(), func(delta: int) -> void:
		_idx_blusa = posmod(_idx_blusa + delta, PALETA_BLUSA.size())
	)
	_vincular_seletor("Roupa", PALETA_BLUSA.size(), func(delta: int) -> void:
		_idx_blusa = posmod(_idx_blusa + delta, PALETA_BLUSA.size())
	)
	_vincular_seletor("Calca", PALETA_CALCA.size(), func(delta: int) -> void:
		_idx_calca = posmod(_idx_calca + delta, PALETA_CALCA.size())
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
	# Atualiza Cores de Pré-visualização nos cartões de seleção
	if is_instance_valid(color_rect_pele):
		color_rect_pele.color = PALETA_PELE[_idx_pele]
	if is_instance_valid(color_rect_cabelo):
		color_rect_cabelo.color = PALETA_CABELO[_idx_cabelo_cor]
	if is_instance_valid(color_rect_blusa):
		color_rect_blusa.color = PALETA_BLUSA[_idx_blusa % PALETA_BLUSA.size()]
	if is_instance_valid(color_rect_calca):
		color_rect_calca.color = PALETA_CALCA[_idx_calca % PALETA_CALCA.size()]
	if is_instance_valid(color_rect_sapato):
		color_rect_sapato.color = PALETA_SAPATO[_idx_sapato % PALETA_SAPATO.size()]
	if is_instance_valid(color_rect_mochila):
		color_rect_mochila.color = PALETA_MOCHILA[_idx_mochila % PALETA_MOCHILA.size()]

	# Atualiza Texto do Estilo de Cabelo
	if is_instance_valid(label_valor_cabelo_estilo):
		label_valor_cabelo_estilo.text = NOMES_ESTILOS_CABELO[_idx_cabelo_estilo]

	# Atualiza Destaque dos Botões de Sexo
	if is_instance_valid(btn_sexo_masc):
		btn_sexo_masc.modulate = Color(1.2, 1.15, 0.8) if _sexo == "masculino" else Color(0.7, 0.7, 0.7)
	if is_instance_valid(btn_sexo_fem):
		btn_sexo_fem.modulate = Color(1.2, 1.15, 0.8) if _sexo == "feminina" else Color(0.7, 0.7, 0.7)

	# Atualiza o AvatarVisual no preview em tempo real
	if is_instance_valid(avatar_preview) and avatar_preview.has_method("aplicar_configuracao"):
		var estilo_chave: String = CHAVES_ESTILOS_CABELO[_idx_cabelo_estilo]
		var config: Dictionary = {
			"sexo": _sexo,
			"estilo_cabelo": estilo_chave,
			"cor_pele": PALETA_PELE[_idx_pele],
			"cor_cabelo": PALETA_CABELO[_idx_cabelo_cor],
			"cor_blusa": PALETA_BLUSA[_idx_blusa % PALETA_BLUSA.size()],
			"cor_calca": PALETA_CALCA[_idx_calca % PALETA_CALCA.size()],
			"cor_sapato": PALETA_SAPATO[_idx_sapato % PALETA_SAPATO.size()],
			"cor_mochila": PALETA_MOCHILA[_idx_mochila % PALETA_MOCHILA.size()]
		}
		avatar_preview.aplicar_configuracao(config)

	_atualizar_resumo()


func _atualizar_resumo() -> void:
	if is_instance_valid(label_resumo_personagem):
		var nome_txt: String = line_edit_nome.text.strip_edges() if is_instance_valid(line_edit_nome) and line_edit_nome.text.strip_edges() != "" else "Bento"
		var estilo_nome: String = NOMES_ESTILOS_CABELO[_idx_cabelo_estilo]
		label_resumo_personagem.text = "%s  •  %s  •  Cabelo %s" % [
			nome_txt,
			"Menino" if _sexo == "masculino" else "Menina",
			estilo_nome
		]


func _salvar_no_global() -> void:
	if not Engine.has_singleton("Global") and not has_node("/root/Global"):
		return
	var g: Node = get_node("/root/Global")
	var nome_final: String = line_edit_nome.text.strip_edges() if is_instance_valid(line_edit_nome) and line_edit_nome.text.strip_edges() != "" else "Bento"
	var estilo_chave: String = CHAVES_ESTILOS_CABELO[_idx_cabelo_estilo]
	
	g.nome_personagem = nome_final
	g.sexo = _sexo
	g.estilo_cabelo = estilo_chave
	
	g.idx_pele = _idx_pele
	g.idx_cabelo_cor = _idx_cabelo_cor
	g.idx_cabelo_estilo = _idx_cabelo_estilo
	g.idx_blusa = _idx_blusa
	g.idx_calca = _idx_calca
	g.idx_sapato = _idx_sapato
	g.idx_mochila = _idx_mochila

	# Salva todas as 6 cores no Autoload
	g.cor_pele = PALETA_PELE[_idx_pele]
	g.cor_cabelo = PALETA_CABELO[_idx_cabelo_cor]
	g.cor_blusa = PALETA_BLUSA[_idx_blusa % PALETA_BLUSA.size()]
	g.cor_calca = PALETA_CALCA[_idx_calca % PALETA_CALCA.size()]
	g.cor_roupa = g.cor_blusa
	g.cor_sapato = PALETA_SAPATO[_idx_sapato % PALETA_SAPATO.size()]
	g.cor_mochila = PALETA_MOCHILA[_idx_mochila % PALETA_MOCHILA.size()]

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
