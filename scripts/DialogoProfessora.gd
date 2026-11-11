extends CanvasLayer
## Controlador do Diálogo da Professora e do Guia de Como Jogar no Museu.
## - A professora fica do lado direito durante a introdução.
## - O jogador fica invisível e bloqueado durante a fala da professora.
## - Ao terminar as falas:
##   1. A professora e a caixa de diálogo somem com fade-out.
##   2. A professora reaparece no cantinho perto dos quadros (ex: x=980, y=520).
##   3. O jogador aparece na tela com fade-in.
##   4. Abre o Guia do Jogo ("COMO JOGAR").
##   5. Quando o jogador fecha o guia, ele é liberado para andar pelo museu.

signal dialogo_finalizado
signal guia_fechado

@export var velocidade_caractere: float = 0.035
@export var caminho_jogador_root: NodePath = ^"../PlayerMuseu"
@export var caminho_jogador: NodePath = ^"../PlayerMuseu/CharacterBody2D"
@export var caminho_professora_root: NodePath = ^"../ProfessoraNPC"
@export var caminho_professora: NodePath = ^"../ProfessoraNPC/CharacterBody2D/AnimatedSprite2D"

# Posição da professora perto do quadro após a introdução
@export var posicao_professora_quadro: Vector2 = Vector2(980, 520)

const FALAS: Array[String] = [
	"Bom dia, turma! Bem-vindos à nossa aula de campo no Espaço Cultural Unifor.",
	"Hoje vamos investigar a nossa cultura regional e descobrir mais sobre como temos uma diversidade imensa de histórias aqui no Ceará.",
	"Fiquem à vontade para explorar as obras. E lembrem-se: museu é história viva!"
]

var _indice_fala: int = 0
var _digitando: bool = false
var _tween_texto: Tween

@onready var painel_dialogo: Control = $PainelDialogo as Control
@onready var label_texto: RichTextLabel = $PainelDialogo/MarginContainer/VBox/RichTextLabel as RichTextLabel
@onready var label_indicador: Label = $PainelDialogo/MarginContainer/VBox/HBox/LabelIndicador as Label

@onready var painel_guia: Control = get_node_or_null("PainelGuiaComoJogar") as Control
@onready var botao_fechar_guia: Button = (find_child("BotaoFecharGuia", true, false) as Button) if has_node("PainelGuiaComoJogar") else null

@onready var player_root: Node2D = get_node_or_null(caminho_jogador_root) as Node2D
@onready var player: CharacterBody2D = get_node_or_null(caminho_jogador) as CharacterBody2D

@onready var professora_root: Node2D = get_node_or_null(caminho_professora_root) as Node2D
@onready var professora_sprite: AnimatedSprite2D = get_node_or_null(caminho_professora) as AnimatedSprite2D


func _ready() -> void:
	# 1. Bloqueia o jogador
	_definir_bloqueio_jogador(true)

	# 2. Mantém o jogador invisível enquanto a professora faz a introdução para a turma
	if is_instance_valid(player_root):
		player_root.visible = false
		player_root.modulate.a = 0.0

	# 3. Oculta o guia inicialmente
	if is_instance_valid(painel_guia):
		painel_guia.visible = false

	# Conecta botão de fechar guia
	if is_instance_valid(botao_fechar_guia):
		botao_fechar_guia.pressed.connect(_on_fechar_guia_pressed)

	# 4. Inicia o diálogo na primeira frase
	_iniciar_dialogo()


func _unhandled_input(event: InputEvent) -> void:
	# Se o guia estiver aberto, tecla Enter / Espaço fecha o guia
	if is_instance_valid(painel_guia) and painel_guia.visible:
		if event.is_action_pressed("ui_accept"):
			_on_fechar_guia_pressed()
			get_viewport().set_input_as_handled()
			return

	# Avanço do diálogo da professora
	if painel_dialogo.visible:
		if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			_avancar_dialogo()
			get_viewport().set_input_as_handled()


func _iniciar_dialogo() -> void:
	painel_dialogo.visible = true
	painel_dialogo.modulate.a = 1.0
	_indice_fala = 0
	_exibir_fala_atual()


func _exibir_fala_atual() -> void:
	if _indice_fala >= FALAS.size():
		_concluir_dialogo()
		return

	var texto_completo: String = FALAS[_indice_fala]
	label_texto.text = texto_completo
	label_texto.visible_characters = 0
	_digitando = true

	if is_instance_valid(label_indicador):
		label_indicador.visible = false

	# Professora ativa animação de 'falar'
	_definir_animacao_professora("falar")

	# Efeito Máquina de Escrever com Tween
	if is_instance_valid(_tween_texto):
		_tween_texto.kill()

	var duracao: float = float(texto_completo.length()) * velocidade_caractere
	_tween_texto = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_tween_texto.tween_property(label_texto, "visible_characters", texto_completo.length(), duracao)
	_tween_texto.tween_callback(_ao_terminar_digitacao)


func _ao_terminar_digitacao() -> void:
	_digitando = false
	label_texto.visible_characters = -1
	# Quando termina a frase atual, volta para idle
	_definir_animacao_professora("idle")
	if is_instance_valid(label_indicador):
		label_indicador.visible = true


func _avancar_dialogo() -> void:
	if _digitando:
		if is_instance_valid(_tween_texto):
			_tween_texto.kill()
		_ao_terminar_digitacao()
	else:
		_indice_fala += 1
		_exibir_fala_atual()


func _concluir_dialogo() -> void:
	_definir_animacao_professora("idle")

	# 1. Fade-out simultâneo da caixa de diálogo e da professora na frente da turma
	var tween_fade_out: Tween = create_tween().set_parallel(true)
	tween_fade_out.tween_property(painel_dialogo, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if is_instance_valid(professora_root):
		tween_fade_out.tween_property(professora_root, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	tween_fade_out.chain().tween_callback(_ao_concluir_fade_out_inicial)
	dialogo_finalizado.emit()


func _ao_concluir_fade_out_inicial() -> void:
	painel_dialogo.visible = false

	# 2. Reposiciona a professora no cantinho perto dos quadros
	if is_instance_valid(professora_root):
		professora_root.global_position = posicao_professora_quadro
		# Fade-in suave da professora em sua nova posição
		var tween_prof: Tween = create_tween()
		tween_prof.tween_property(professora_root, "modulate:a", 1.0, 0.5)

	# 3. Coloca o personagem na tela com fade-in
	if is_instance_valid(player_root):
		player_root.visible = true
		var tween_player: Tween = create_tween()
		tween_player.tween_property(player_root, "modulate:a", 1.0, 0.5)

	# 4. Abre o guia sobre o jogo na tela com animação pop-in
	_abrir_guia_jogo()


func _abrir_guia_jogo() -> void:
	if not is_instance_valid(painel_guia):
		# Se não houver painel de guia, libera o jogador imediatamente
		_definir_bloqueio_jogador(false)
		return

	painel_guia.visible = true
	painel_guia.modulate.a = 0.0
	painel_guia.scale = Vector2(0.92, 0.92)
	painel_guia.pivot_offset = painel_guia.size * 0.5

	var tween_guia: Tween = create_tween().set_parallel(true)
	tween_guia.tween_property(painel_guia, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_guia.tween_property(painel_guia, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if is_instance_valid(botao_fechar_guia):
		botao_fechar_guia.grab_focus()


func _on_fechar_guia_pressed() -> void:
	if is_instance_valid(painel_guia):
		var tween_fechar: Tween = create_tween().set_parallel(true)
		tween_fechar.tween_property(painel_guia, "modulate:a", 0.0, 0.2)
		tween_fechar.tween_property(painel_guia, "scale", Vector2(0.94, 0.94), 0.2)
		tween_fechar.chain().tween_callback(func() -> void:
			painel_guia.visible = false
			# Desbloqueia o jogador para andar pelo museu
			_definir_bloqueio_jogador(false)
			guia_fechado.emit()
		)
	else:
		_definir_bloqueio_jogador(false)
		guia_fechado.emit()


func _definir_bloqueio_jogador(bloquear: bool) -> void:
	if is_instance_valid(player):
		player.set("bloqueado", bloquear)


func _definir_animacao_professora(anim_nome: String) -> void:
	if is_instance_valid(professora_sprite) and is_instance_valid(professora_sprite.sprite_frames):
		if professora_sprite.sprite_frames.has_animation(anim_nome):
			professora_sprite.play(anim_nome)
		elif anim_nome == "falar" and professora_sprite.sprite_frames.has_animation("personagem andando"):
			professora_sprite.play("personagem andando")
		elif anim_nome == "idle" and professora_sprite.sprite_frames.has_animation("personagem parada"):
			professora_sprite.play("personagem parada")
