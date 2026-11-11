extends Control
## Controlador do menu de opções com feedback visual via Tweens e efeitos sonoros.

signal exit_options_menu

const SOM_NAVEGAR: AudioStream = preload("res://audios/ui/menu_navegar.ogg")
const SOM_VOLTAR: AudioStream = preload("res://audios/ui/menu_voltar.ogg")

const ESCALA_NORMAL: Vector2 = Vector2.ONE
const ESCALA_HOVER: Vector2 = Vector2(1.06, 1.06)
const ESCALA_PRESSIONADO: Vector2 = Vector2(0.94, 0.94)

var _player_sfx: AudioStreamPlayer
var _tweens_controles: Dictionary[Control, Tween] = {}

@onready var botao_voltar: Button = get_node_or_null("back") as Button
@onready var check_tela_cheia: CheckButton = get_node_or_null("telaCheia") as CheckButton
@onready var slider_musica: HSlider = get_node_or_null("musica") as HSlider
@onready var slider_efeitos: HSlider = get_node_or_null("efeitos") as HSlider


func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos"
	add_child(_player_sfx)

	_configurar_interacao_controle(botao_voltar)
	_configurar_interacao_controle(check_tela_cheia)
	_configurar_interacao_controle(slider_musica)
	_configurar_interacao_controle(slider_efeitos)


func _on_back_pressed() -> void:
	_tocar_sfx(SOM_VOLTAR)
	exit_options_menu.emit()


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
	var cor_alvo: Color = Color(1.12, 1.08, 1.0, 1.0) if ativo else Color.WHITE

	var tween: Tween = create_tween().set_parallel(true)
	_tweens_controles[controle] = tween
	tween.tween_property(controle, "scale", escala_alvo, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(controle, "modulate", cor_alvo, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


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
