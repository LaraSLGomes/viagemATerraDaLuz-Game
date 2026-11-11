extends Control
## Controlador da tela inicial com animações de Game Feel (Tweens) e feedback sonoro.

const CENA_PERSONAGENS: String = "res://cenas/personagens.tscn"
const CENA_LOBBY: String = "res://cenas/lobby_scene.tscn"

const SOM_NAVEGAR: AudioStream = preload("res://audios/ui/menu_navegar.ogg")
const SOM_CONFIRMAR: AudioStream = preload("res://audios/ui/menu_confirmar.ogg")

const ESCALA_NORMAL: Vector2 = Vector2.ONE
const ESCALA_HOVER: Vector2 = Vector2(1.06, 1.06)
const ESCALA_PRESSIONADO: Vector2 = Vector2(0.95, 0.95)
const COR_NORMAL: Color = Color(1.0, 1.0, 1.0, 1.0)
const COR_HOVER: Color = Color(1.16, 1.12, 1.02, 1.0)

var _em_transicao: bool = false
var _player_sfx: AudioStreamPlayer
var _tweens_botoes: Dictionary[Button, Tween] = {}

@onready var options_menu: Control = get_node_or_null("options_menu") as Control
@onready var jogos_salvos_menu: Control = get_node_or_null("jogos_salvos") as Control
@onready var menu_container: Control = (
	get_node_or_null("MenuContainer") as Control
	if has_node("MenuContainer")
	else get_node_or_null("MarginContainer") as Control
)
@onready var background: VideoStreamPlayer = get_node_or_null("VideoBackground") as VideoStreamPlayer
@onready var start_button: Button = find_child("BotaoNovoJogo", true, false) as Button
@onready var saved_games_button: Button = find_child("BotaoJogosSalvos", true, false) as Button


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_configurar_audio_ui()

	if is_instance_valid(background) and background.stream != null:
		background.visible = true
		background.play()

	_configurar_botoes_game_feel()
	_animar_entrada_menu()

	if is_instance_valid(start_button):
		start_button.grab_focus()



func _on_start_btn_pressed() -> void:
	if _em_transicao:
		return
	_em_transicao = true
	_tocar_sfx(SOM_CONFIRMAR)

	var tween: Tween = create_tween().set_parallel(true)
	if is_instance_valid(menu_container):
		tween.tween_property(menu_container, "modulate:a", 0.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(menu_container, "scale", Vector2(1.05, 1.05), 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color(1.3, 1.25, 1.1, 0.0), 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_ir_para_personagens)


func _on_option_btn_pressed() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	if is_instance_valid(menu_container):
		var tween_saida: Tween = create_tween()
		tween_saida.tween_property(menu_container, "modulate:a", 0.0, 0.15)
		tween_saida.tween_callback(func() -> void: menu_container.visible = false)

	if is_instance_valid(options_menu):
		options_menu.visible = true
		options_menu.modulate.a = 0.0
		options_menu.scale = Vector2(0.96, 0.96)
		options_menu.pivot_offset = options_menu.size * 0.5
		var tween_entrada: Tween = create_tween().set_parallel(true)
		tween_entrada.tween_property(options_menu, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_entrada.tween_property(options_menu, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_saved_games_btn_pressed() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	if is_instance_valid(menu_container):
		var tween_saida: Tween = create_tween()
		tween_saida.tween_property(menu_container, "modulate:a", 0.0, 0.15)
		tween_saida.tween_callback(func() -> void: menu_container.visible = false)

	if is_instance_valid(jogos_salvos_menu):
		jogos_salvos_menu.visible = true
		jogos_salvos_menu.modulate.a = 0.0
		jogos_salvos_menu.scale = Vector2(0.96, 0.96)
		jogos_salvos_menu.pivot_offset = jogos_salvos_menu.size * 0.5
		var tween_entrada: Tween = create_tween().set_parallel(true)
		tween_entrada.tween_property(jogos_salvos_menu, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_entrada.tween_property(jogos_salvos_menu, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_jogos_salvos_fechar() -> void:
	if is_instance_valid(jogos_salvos_menu):
		var tween_fechar: Tween = create_tween()
		tween_fechar.tween_property(jogos_salvos_menu, "modulate:a", 0.0, 0.16)
		tween_fechar.tween_callback(func() -> void: jogos_salvos_menu.visible = false)

	if is_instance_valid(menu_container):
		menu_container.visible = true
		menu_container.modulate.a = 0.0
		var tween_abrir: Tween = create_tween()
		tween_abrir.tween_property(menu_container, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if is_instance_valid(saved_games_button):
		saved_games_button.grab_focus()


func _on_quit_btn_pressed() -> void:
	if _em_transicao:
		return
	_em_transicao = true
	_tocar_sfx(SOM_CONFIRMAR)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: get_tree().quit())


func _on_options_menu_exit_options_menu() -> void:
	if is_instance_valid(options_menu):
		var tween_fechar: Tween = create_tween()
		tween_fechar.tween_property(options_menu, "modulate:a", 0.0, 0.16)
		tween_fechar.tween_callback(func() -> void: options_menu.visible = false)

	if is_instance_valid(menu_container):
		menu_container.visible = true
		menu_container.modulate.a = 0.0
		var tween_abrir: Tween = create_tween()
		tween_abrir.tween_property(menu_container, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if is_instance_valid(start_button):
		start_button.grab_focus()


func _configurar_audio_ui() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos"
	add_child(_player_sfx)


func _tocar_sfx(stream: AudioStream) -> void:
	if is_instance_valid(_player_sfx) and stream != null:
		_player_sfx.stream = stream
		_player_sfx.pitch_scale = randf_range(0.96, 1.04)
		_player_sfx.play()


func _animar_entrada_menu() -> void:
	if not is_instance_valid(menu_container):
		return
	menu_container.modulate.a = 0.0
	var pos_final: Vector2 = menu_container.position
	menu_container.position = pos_final + Vector2(0.0, 18.0)

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(menu_container, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(menu_container, "position", pos_final, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _configurar_botoes_game_feel() -> void:
	if not is_instance_valid(menu_container):
		return

	var nos_botoes: Array[Node] = menu_container.find_children("*", "Button", true, false)
	for no: Node in nos_botoes:
		var botao: Button = no as Button
		if not is_instance_valid(botao):
			continue
		botao.resized.connect(func() -> void: botao.pivot_offset = botao.size * 0.5)
		botao.pivot_offset = botao.size * 0.5
		botao.mouse_entered.connect(func() -> void: _animar_botao_hover(botao, true))
		botao.mouse_exited.connect(func() -> void: _animar_botao_hover(botao, false))
		botao.focus_entered.connect(func() -> void: _animar_botao_hover(botao, true))
		botao.focus_exited.connect(func() -> void: _animar_botao_hover(botao, false))
		botao.button_down.connect(func() -> void: _animar_botao_pressionado(botao, true))
		botao.button_up.connect(func() -> void: _animar_botao_pressionado(botao, false))


func _animar_botao_hover(botao: Button, ativo: bool) -> void:
	if not is_instance_valid(botao):
		return
	botao.pivot_offset = botao.size * 0.5
	if ativo:
		_tocar_sfx(SOM_NAVEGAR)

	if _tweens_botoes.has(botao) and is_instance_valid(_tweens_botoes[botao]):
		_tweens_botoes[botao].kill()

	var escala_alvo: Vector2 = ESCALA_HOVER if ativo else ESCALA_NORMAL
	var cor_alvo: Color = COR_HOVER if ativo else COR_NORMAL

	var tween: Tween = create_tween().set_parallel(true)
	_tweens_botoes[botao] = tween
	tween.tween_property(botao, "scale", escala_alvo, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(botao, "self_modulate", cor_alvo, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _animar_botao_pressionado(botao: Button, pressionado: bool) -> void:
	if not is_instance_valid(botao):
		return
	botao.pivot_offset = botao.size * 0.5

	if _tweens_botoes.has(botao) and is_instance_valid(_tweens_botoes[botao]):
		_tweens_botoes[botao].kill()

	var escala_alvo: Vector2 = ESCALA_PRESSIONADO if pressionado else ESCALA_HOVER
	var tween: Tween = create_tween()
	_tweens_botoes[botao] = tween
	tween.tween_property(botao, "scale", escala_alvo, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _ir_para_personagens() -> void:
	get_tree().change_scene_to_file(CENA_PERSONAGENS)


func _ir_para_lobby() -> void:
	get_tree().change_scene_to_file(CENA_LOBBY)
