extends Node2D
## Controlador da ambientação do Museu (Museu da UNIFOR - Hub da História)
## Gerencia a atmosfera solene do museu, interação com quadros-portais e HUD/Opções.

const CENA_PUZZLE_UM: String = "res://cenas/puzzle_um.tscn"

var _em_transicao: bool = false

@onready var options_menu: Control = find_child("options_menu", true, false) as Control
@onready var btn_config: Button = find_child("BotaoConfiguracoesHUD", true, false) as Button
@onready var label_nome_player: Label = find_child("LabelNomePlayer", true, false) as Label
@onready var label_dica_interacao: Label = find_child("LabelDicaInteracao", true, false) as Label
@onready var player: CharacterBody2D = find_child("PlayerMuseu", true, false) as CharacterBody2D
@onready var area_portal_quadro: Area2D = find_child("AreaPortalQuadro", true, false) as Area2D

var _jogador_proximo_quadro: bool = false


func _ready() -> void:
	if is_instance_valid(btn_config):
		btn_config.pressed.connect(_abrir_configuracoes)

	if is_instance_valid(options_menu):
		options_menu.visible = false
		if not options_menu.exit_options_menu.is_connected(_fechar_configuracoes):
			options_menu.exit_options_menu.connect(_fechar_configuracoes)

	# Atualiza o nome do protagonista personalizado
	if is_instance_valid(label_nome_player):
		var nome_heroi: String = "Bento"
		if Engine.has_singleton("Global") or has_node("/root/Global"):
			var g: Node = get_node("/root/Global")
			nome_heroi = str(g.nome_personagem)
		label_nome_player.text = "Expedição: %s" % nome_heroi

	if is_instance_valid(area_portal_quadro):
		area_portal_quadro.body_entered.connect(_on_portal_body_entered)
		area_portal_quadro.body_exited.connect(_on_portal_body_exited)

	if is_instance_valid(label_dica_interacao):
		label_dica_interacao.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(options_menu):
			if options_menu.visible:
				_fechar_configuracoes()
			else:
				_abrir_configuracoes()
			get_viewport().set_input_as_handled()
			return

	if _jogador_proximo_quadro and not _em_transicao:
		if event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
			_entrar_no_quadro_portal()
			get_viewport().set_input_as_handled()


func _on_portal_body_entered(body: Node2D) -> void:
	if body == player or body.is_in_group("player"):
		_jogador_proximo_quadro = true
		if is_instance_valid(label_dica_interacao):
			label_dica_interacao.visible = true


func _on_portal_body_exited(body: Node2D) -> void:
	if body == player or body.is_in_group("player"):
		_jogador_proximo_quadro = false
		if is_instance_valid(label_dica_interacao):
			label_dica_interacao.visible = false


func _entrar_no_quadro_portal() -> void:
	_em_transicao = true
	var tween: Tween = create_tween().set_parallel(true)
	var fade_overlay: ColorRect = find_child("FadeTransicao", true, false) as ColorRect
	if is_instance_valid(fade_overlay):
		fade_overlay.visible = true
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
	tween.chain().tween_callback(func() -> void:
		get_tree().change_scene_to_file(CENA_PUZZLE_UM)
	)


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
