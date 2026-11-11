extends Node2D
## Controlador do Lobby/Museu (ponto de partida de Novo Jogo)
## Gerencia abertura/fechamento do menu de opções no jogo e retorno ao Menu Principal ou à jogatina.

@onready var options_menu: Control = find_child("options_menu", true, false) as Control
@onready var btn_config: Button = find_child("BotaoConfiguracoesHUD", true, false) as Button


func _ready() -> void:
	if is_instance_valid(btn_config):
		btn_config.pressed.connect(_abrir_configuracoes)

	if is_instance_valid(options_menu):
		options_menu.visible = false
		if not options_menu.exit_options_menu.is_connected(_fechar_configuracoes):
			options_menu.exit_options_menu.connect(_fechar_configuracoes)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(options_menu):
			if options_menu.visible:
				_fechar_configuracoes()
			else:
				_abrir_configuracoes()
			get_viewport().set_input_as_handled()


func _abrir_configuracoes() -> void:
	if is_instance_valid(options_menu):
		options_menu.visible = true
		options_menu.modulate.a = 0.0
		options_menu.scale = Vector2(0.96, 0.96)
		options_menu.pivot_offset = options_menu.size * 0.5
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(options_menu, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(options_menu, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _fechar_configuracoes() -> void:
	if is_instance_valid(options_menu):
		var tween: Tween = create_tween()
		tween.tween_property(options_menu, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func() -> void: options_menu.visible = false)
