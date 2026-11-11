extends Node2D
## Controlador da Fase Introdutória: Museu do Ceará (Prólogo)
## Rascunho inicial com iluminação, partículas do portal e suporte ao menu de opções / diálogo.

@onready var options_menu: Control = find_child("options_menu", true, false) as Control
@onready var btn_config: Button = find_child("BotaoConfiguracoesHUD", true, false) as Button
@onready var label_intro: Label = find_child("LabelIntro", true, false) as Label
@onready var label_nome_player: Label = find_child("LabelNomePlayer", true, false) as Label


func _ready() -> void:
	if is_instance_valid(btn_config):
		btn_config.pressed.connect(_abrir_configuracoes)

	if is_instance_valid(options_menu):
		options_menu.visible = false
		if not options_menu.exit_options_menu.is_connected(_fechar_configuracoes):
			options_menu.exit_options_menu.connect(_fechar_configuracoes)

	# Atualiza com os dados do personagem customizado vindos do Global
	if is_instance_valid(label_nome_player):
		var nome_heroi: String = "Bento"
		if Engine.has_singleton("Global") or has_node("/root/Global"):
			var g: Node = get_node("/root/Global")
			nome_heroi = str(g.nome_personagem)
		label_nome_player.text = "Expedição: %s" % nome_heroi


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
