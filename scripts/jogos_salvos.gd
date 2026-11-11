extends Control
## Controlador do painel de Jogos Salvos (Save / Load Game) com estética de pergaminho.

signal fechar_jogos_salvos

const CAMINHO_SAVES_DIR: String = "user://saves/"
const SOM_NAVEGAR: AudioStream = preload("res://audios/ui/menu_navegar.ogg")
const SOM_CONFIRMAR: AudioStream = preload("res://audios/ui/menu_confirmar.ogg")
const CENA_LOBBY: String = "res://cenas/lobby_scene.tscn"

const ESCALA_NORMAL: Vector2 = Vector2.ONE
const ESCALA_HOVER: Vector2 = Vector2(1.04, 1.04)
const ESCALA_PRESSIONADO: Vector2 = Vector2(0.96, 0.96)

var _player_sfx: AudioStreamPlayer
var _tweens_botoes: Dictionary[Button, Tween] = {}

@onready var btn_voltar: Button = find_child("BotaoVoltar", true, false) as Button
@onready var container_slots: VBoxContainer = find_child("SlotsContainer", true, false) as VBoxContainer


func _ready() -> void:
	_configurar_audio()
	_configurar_slots()
	_configurar_efeitos_botoes()
	if is_instance_valid(btn_voltar):
		btn_voltar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_botao_voltar_pressed()
		get_viewport().set_input_as_handled()


func _configurar_audio() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"SFX" if AudioServer.get_bus_index("SFX") != -1 else &"Master"
	add_child(_player_sfx)


func _tocar_sfx(stream: AudioStream) -> void:
	if is_instance_valid(_player_sfx) and stream != null:
		_player_sfx.stream = stream
		_player_sfx.play()


func _configurar_efeitos_botoes() -> void:
	for node: Node in find_children("*", "Button", true, false):
		var btn: Button = node as Button
		if not is_instance_valid(btn):
			continue
		btn.pivot_offset = btn.size * 0.5
		btn.mouse_entered.connect(_ao_mouse_entrar_botao.bind(btn))
		btn.mouse_exited.connect(_ao_mouse_sair_botao.bind(btn))
		btn.button_down.connect(_ao_pressionar_botao.bind(btn))
		btn.button_up.connect(_ao_soltar_botao.bind(btn))


func _ao_mouse_entrar_botao(btn: Button) -> void:
	_tocar_sfx(SOM_NAVEGAR)
	_animar_escala_botao(btn, ESCALA_HOVER, 0.12)


func _ao_mouse_sair_botao(btn: Button) -> void:
	_animar_escala_botao(btn, ESCALA_NORMAL, 0.14)


func _ao_pressionar_botao(btn: Button) -> void:
	_animar_escala_botao(btn, ESCALA_PRESSIONADO, 0.08)


func _ao_soltar_botao(btn: Button) -> void:
	_animar_escala_botao(btn, ESCALA_HOVER if btn.is_hovered() else ESCALA_NORMAL, 0.1)


func _animar_escala_botao(btn: Button, target_scale: Vector2, duration: float) -> void:
	if _tweens_botoes.has(btn) and is_instance_valid(_tweens_botoes[btn]):
		_tweens_botoes[btn].kill()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn, "scale", target_scale, duration)
	_tweens_botoes[btn] = tween


func _configurar_slots() -> void:
	# Dados de slots simulados ou carregados do disco
	var slots_info: Array[Dictionary] = [
		{
			"id": 1,
			"ocupado": true,
			"nome": "Bento",
			"fase": "Fase 1: Jangadas e Liberdade • 1884",
			"data": "11/11/2026 14:30",
			"tempo": "00h 42m",
		},
		{
			"id": 2,
			"ocupado": true,
			"nome": "Maria Flor",
			"fase": "Prólogo: Museu do Ceará • Presente",
			"data": "10/11/2026 18:15",
			"tempo": "00h 15m",
		},
		{
			"id": 3,
			"ocupado": false,
			"nome": "Espaço Livre",
			"fase": "Novo Registro Histórico",
			"data": "--/--/---- --:--",
			"tempo": "00h 00m",
		}
	]

	for slot_data: Dictionary in slots_info:
		var slot_idx: int = int(slot_data["id"])
		var slot_panel: PanelContainer = find_child("Slot_%d" % slot_idx, true, false) as PanelContainer
		if not is_instance_valid(slot_panel):
			continue

		var lbl_nome: Label = slot_panel.find_child("LabelNomeSlot", true, false) as Label
		var lbl_detalhes: Label = slot_panel.find_child("LabelDetalhesSlot", true, false) as Label
		var btn_carregar: Button = slot_panel.find_child("BotaoCarregar", true, false) as Button
		var btn_excluir: Button = slot_panel.find_child("BotaoExcluir", true, false) as Button

		var ocupado: bool = bool(slot_data["ocupado"])
		if is_instance_valid(lbl_nome):
			if ocupado:
				lbl_nome.text = "SLOT %d: %s" % [slot_idx, str(slot_data["nome"])]
			else:
				lbl_nome.text = "SLOT %d: [ VAZIO ]" % slot_idx

		if is_instance_valid(lbl_detalhes):
			if ocupado:
				lbl_detalhes.text = "%s\nÚltimo Acesso: %s  |  Tempo: %s" % [
					str(slot_data["fase"]),
					str(slot_data["data"]),
					str(slot_data["tempo"])
				]
			else:
				lbl_detalhes.text = "Nenhum progresso gravado neste pergaminho.\nSelecione Novo Jogo na tela principal."

		if is_instance_valid(btn_carregar):
			btn_carregar.disabled = not ocupado
			if not btn_carregar.pressed.is_connected(_on_carregar_slot_pressed):
				btn_carregar.pressed.connect(_on_carregar_slot_pressed.bind(slot_idx))

		if is_instance_valid(btn_excluir):
			btn_excluir.disabled = not ocupado
			if not btn_excluir.pressed.is_connected(_on_excluir_slot_pressed):
				btn_excluir.pressed.connect(_on_excluir_slot_pressed.bind(slot_idx))


func _on_carregar_slot_pressed(slot_idx: int) -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(func() -> void:
		get_tree().change_scene_to_file(CENA_LOBBY)
	)


func _on_excluir_slot_pressed(slot_idx: int) -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	var slot_panel: PanelContainer = find_child("Slot_%d" % slot_idx, true, false) as PanelContainer
	if not is_instance_valid(slot_panel):
		return
	var lbl_nome: Label = slot_panel.find_child("LabelNomeSlot", true, false) as Label
	var lbl_detalhes: Label = slot_panel.find_child("LabelDetalhesSlot", true, false) as Label
	var btn_carregar: Button = slot_panel.find_child("BotaoCarregar", true, false) as Button
	var btn_excluir: Button = slot_panel.find_child("BotaoExcluir", true, false) as Button

	if is_instance_valid(lbl_nome):
		lbl_nome.text = "SLOT %d: [ VAZIO ]" % slot_idx
	if is_instance_valid(lbl_detalhes):
		lbl_detalhes.text = "Nenhum progresso gravado neste pergaminho.\nSelecione Novo Jogo na tela principal."
	if is_instance_valid(btn_carregar):
		btn_carregar.disabled = true
	if is_instance_valid(btn_excluir):
		btn_excluir.disabled = true


func _on_botao_voltar_pressed() -> void:
	_tocar_sfx(SOM_CONFIRMAR)
	fechar_jogos_salvos.emit()
