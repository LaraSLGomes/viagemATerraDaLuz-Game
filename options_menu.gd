extends Control
## Controlador do menu de opções com remapeamento de controles, áudio e tela cheia.

signal exit_options_menu
signal ir_menu_principal

const SOM_NAVEGAR: AudioStream = preload("res://audios/ui/menu_navegar.ogg")
const SOM_VOLTAR: AudioStream = preload("res://audios/ui/menu_voltar.ogg")
const SOM_CONFIRMAR: AudioStream = preload("res://audios/ui/menu_confirmar.ogg")
const CENA_TITLE_SCREEN: String = "res://cenas/title_screen.tscn"

const ESCALA_NORMAL: Vector2 = Vector2.ONE
const ESCALA_HOVER: Vector2 = Vector2(1.04, 1.04)
const ESCALA_PRESSIONADO: Vector2 = Vector2(0.96, 0.96)

const ACOES_PADRAO: Dictionary[String, Array] = {
	"left": [KEY_A, KEY_LEFT],
	"right": [KEY_D, KEY_RIGHT],
	"up": [KEY_W, KEY_UP],
	"down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE]
}

var _player_sfx: AudioStreamPlayer
var _tweens_controles: Dictionary[Control, Tween] = {}
var _acao_aguardando_tecla: String = ""
var _botao_aguardando: Button = null

@onready var botao_voltar: Button = find_child("back", true, false) as Button
@onready var botao_menu_principal: Button = find_child("btnMenuPrincipal", true, false) as Button
@onready var check_tela_cheia: CheckButton = get_node_or_null("telaCheia") as CheckButton
@onready var slider_musica: HSlider = get_node_or_null("musica") as HSlider
@onready var slider_efeitos: HSlider = get_node_or_null("efeitos") as HSlider

@onready var aba_diario: Button = get_node_or_null("AbaDiario") as Button
@onready var aba_controles: Button = get_node_or_null("AbaControles") as Button
@onready var painel_diario: Control = get_node_or_null("PainelDiario") as Control
@onready var painel_controles: Control = get_node_or_null("PainelControles") as Control

@onready var btn_key_left: Button = find_child("BtnKey_left", true, false) as Button
@onready var btn_key_right: Button = find_child("BtnKey_right", true, false) as Button
@onready var btn_key_up: Button = find_child("BtnKey_up", true, false) as Button
@onready var btn_key_down: Button = find_child("BtnKey_down", true, false) as Button
@onready var btn_key_jump: Button = find_child("BtnKey_jump", true, false) as Button
@onready var btn_restaurar_padrao: Button = find_child("BtnRestaurarPadrao", true, false) as Button
@onready var label_dica: Label = find_child("LabelDica", true, false) as Label


func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos"
	add_child(_player_sfx)

	_configurar_interacao_controle(botao_voltar)
	_configurar_interacao_controle(botao_menu_principal)
	_configurar_interacao_controle(check_tela_cheia)
	_configurar_interacao_controle(slider_musica)
	_configurar_interacao_controle(slider_efeitos)

	_configurar_abas()
	_configurar_botoes_teclas()
	_atualizar_rotulos_teclas()



func _unhandled_input(event: InputEvent) -> void:
	if _acao_aguardando_tecla == "":
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_cancelar_remapeamento()
			get_viewport().set_input_as_handled()
			return

		_remapear_acao(_acao_aguardando_tecla, key_event)
		get_viewport().set_input_as_handled()


func _configurar_abas() -> void:
	if is_instance_valid(aba_diario):
		aba_diario.pressed.connect(func() -> void: _alternar_aba(false))
		_configurar_interacao_controle(aba_diario)
	if is_instance_valid(aba_controles):
		aba_controles.pressed.connect(func() -> void: _alternar_aba(true))
		_configurar_interacao_controle(aba_controles)


func _alternar_aba(mostrar_controles: bool) -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	if is_instance_valid(painel_diario):
		painel_diario.visible = not mostrar_controles
	if is_instance_valid(painel_controles):
		painel_controles.visible = mostrar_controles

	if is_instance_valid(aba_diario) and is_instance_valid(aba_controles):
		aba_diario.modulate = Color(0.85, 0.85, 0.85, 1.0) if mostrar_controles else Color(1.15, 1.1, 1.0, 1.0)
		aba_controles.modulate = Color(1.15, 1.1, 1.0, 1.0) if mostrar_controles else Color(0.85, 0.85, 0.85, 1.0)


func _configurar_botoes_teclas() -> void:
	_vincular_botao_acao(btn_key_left, "left")
	_vincular_botao_acao(btn_key_right, "right")
	_vincular_botao_acao(btn_key_up, "up")
	_vincular_botao_acao(btn_key_down, "down")
	_vincular_botao_acao(btn_key_jump, "jump")

	if is_instance_valid(btn_restaurar_padrao):
		btn_restaurar_padrao.pressed.connect(_restaurar_controles_padrao)
		_configurar_interacao_controle(btn_restaurar_padrao)


func _vincular_botao_acao(botao: Button, acao: String) -> void:
	if not is_instance_valid(botao):
		return
	botao.pressed.connect(func() -> void: _iniciar_espera_tecla(acao, botao))
	_configurar_interacao_controle(botao)


func _iniciar_espera_tecla(acao: String, botao: Button) -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	_acao_aguardando_tecla = acao
	_botao_aguardando = botao
	botao.text = "[ Pressione uma tecla ]"
	if is_instance_valid(label_dica):
		label_dica.text = "Pressione a nova tecla (ESC para cancelar)"


func _cancelar_remapeamento() -> void:
	_tocar_sfx(SOM_VOLTAR)
	_acao_aguardando_tecla = ""
	_botao_aguardando = null
	_atualizar_rotulos_teclas()
	if is_instance_valid(label_dica):
		label_dica.text = "Clique no botão e pressione a nova tecla:"


func _remapear_acao(acao: String, event: InputEventKey) -> void:
	if not InputMap.has_action(acao):
		return

	# Remove eventos de teclado antigos dessa ação
	var eventos_antigos: Array[InputEvent] = InputMap.action_get_events(acao)
	for ev in eventos_antigos:
		if ev is InputEventKey:
			InputMap.action_erase_event(acao, ev)

	# Cria o novo evento com tecla física e adiciona
	var novo_evento: InputEventKey = InputEventKey.new()
	novo_evento.physical_keycode = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	novo_evento.keycode = event.keycode
	InputMap.action_add_event(acao, novo_evento)

	_tocar_sfx(SOM_CONFIRMAR)
	_acao_aguardando_tecla = ""
	_botao_aguardando = null
	_atualizar_rotulos_teclas()
	if is_instance_valid(label_dica):
		label_dica.text = "Tecla alterada com sucesso!"


func _restaurar_controles_padrao() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	for acao: String in ACOES_PADRAO:
		if not InputMap.has_action(acao):
			continue
		var eventos: Array[InputEvent] = InputMap.action_get_events(acao)
		for ev in eventos:
			if ev is InputEventKey:
				InputMap.action_erase_event(acao, ev)

		var teclas: Array = ACOES_PADRAO[acao]
		for k in teclas:
			var novo_evento: InputEventKey = InputEventKey.new()
			novo_evento.physical_keycode = k as Key
			novo_evento.keycode = k as Key
			InputMap.action_add_event(acao, novo_evento)

	_atualizar_rotulos_teclas()
	if is_instance_valid(label_dica):
		label_dica.text = "Controles restaurados para o padrão!"


func _atualizar_rotulos_teclas() -> void:
	_definir_texto_botao_acao(btn_key_left, "left")
	_definir_texto_botao_acao(btn_key_right, "right")
	_definir_texto_botao_acao(btn_key_up, "up")
	_definir_texto_botao_acao(btn_key_down, "down")
	_definir_texto_botao_acao(btn_key_jump, "jump")


func _definir_texto_botao_acao(botao: Button, acao: String) -> void:
	if not is_instance_valid(botao) or not InputMap.has_action(acao):
		return
	var nomes: Array[String] = []
	for ev in InputMap.action_get_events(acao):
		if ev is InputEventKey:
			var key_event: InputEventKey = ev as InputEventKey
			var nome: String = OS.get_keycode_string(
				key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
			)
			if nome != "" and not nomes.has(nome):
				nomes.append(nome)
	botao.text = " / ".join(nomes) if not nomes.is_empty() else "[ Não mapeado ]"


func _on_back_pressed() -> void:
	_tocar_sfx(SOM_VOLTAR)
	exit_options_menu.emit()


func _on_menu_principal_pressed() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	ir_menu_principal.emit()
	# Se a cena atual for o lobby/jogo, transiciona diretamente para a tela inicial
	var cena_atual: Node = get_tree().current_scene
	if is_instance_valid(cena_atual) and cena_atual.name != "TelaInicial":
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func() -> void:
			get_tree().change_scene_to_file(CENA_TITLE_SCREEN)
		)


func _on_title_screen_focus_exited() -> void:
	pass



func _configurar_interacao_controle(controle: Control) -> void:
	if not is_instance_valid(controle):
		return
	controle.resized.connect(func() -> void: controle.pivot_offset = controle.size * 0.5)
	controle.pivot_offset = controle.size * 0.5
	controle.mouse_entered.connect(func() -> void: _animar_hover(controle, true))
	controle.mouse_exited.connect(func() -> void: _animar_hover(controle, false))
	controle.focus_entered.connect(func() -> void: _animar_hover(controle, true))
	controle.focus_exited.connect(func() -> void: _animar_hover(controle, false))

	var botao: BaseButton = controle as BaseButton
	if is_instance_valid(botao):
		botao.button_down.connect(func() -> void: _animar_pressionado(controle, true))
		botao.button_up.connect(func() -> void: _animar_pressionado(controle, false))


func _animar_hover(controle: Control, ativo: bool) -> void:
	if not is_instance_valid(controle):
		return
	controle.pivot_offset = controle.size * 0.5
	if ativo:
		_tocar_sfx(SOM_NAVEGAR)

	if _tweens_controles.has(controle) and is_instance_valid(_tweens_controles[controle]):
		_tweens_controles[controle].kill()

	var escala_alvo: Vector2 = ESCALA_HOVER if ativo else ESCALA_NORMAL
	var cor_alvo: Color = Color(1.1, 1.06, 0.98, 1.0) if ativo else Color.WHITE

	var tween: Tween = create_tween().set_parallel(true)
	_tweens_controles[controle] = tween
	tween.tween_property(controle, "scale", escala_alvo, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(controle, "modulate", cor_alvo, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _animar_pressionado(controle: Control, pressionado: bool) -> void:
	if not is_instance_valid(controle):
		return
	controle.pivot_offset = controle.size * 0.5

	if _tweens_controles.has(controle) and is_instance_valid(_tweens_controles[controle]):
		_tweens_controles[controle].kill()

	var escala_alvo: Vector2 = ESCALA_PRESSIONADO if pressionado else ESCALA_HOVER
	var tween: Tween = create_tween()
	_tweens_controles[controle] = tween
	tween.tween_property(controle, "scale", escala_alvo, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _tocar_sfx(stream: AudioStream) -> void:
	if is_instance_valid(_player_sfx) and stream != null:
		_player_sfx.stream = stream
		_player_sfx.pitch_scale = randf_range(0.96, 1.04)
		_player_sfx.play()
