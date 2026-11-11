extends CanvasLayer
## Controlador do Diálogo da Professora na introdução do Museu da UNIFOR.
## Controla efeito máquina de escrever, animações de falar/idle e bloqueio/desbloqueio do jogador.

signal dialogo_finalizado

@export var velocidade_caractere: float = 0.035
@export var caminho_jogador: NodePath = ^"../PlayerMuseu/CharacterBody2D"
@export var caminho_professora: NodePath = ^"../ProfessoraNPC/AnimatedSprite2D"

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
@onready var player: CharacterBody2D = get_node_or_null(caminho_jogador) as CharacterBody2D
@onready var professora_sprite: AnimatedSprite2D = get_node_or_null(caminho_professora) as AnimatedSprite2D


func _ready() -> void:
	# 1. Bloqueia o jogador assim que a cena carrega
	_definir_bloqueio_jogador(true)

	# 2. Inicia o diálogo na primeira frase
	_iniciar_dialogo()


func _unhandled_input(event: InputEvent) -> void:
	if not painel_dialogo.visible:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_avancar_dialogo()
		get_viewport().set_input_as_handled()


func _iniciar_dialogo() -> void:
	painel_dialogo.visible = true
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
	# Quando termina de falar a frase atual, pausa a fala
	_definir_animacao_professora("idle")
	if is_instance_valid(label_indicador):
		label_indicador.visible = true


func _avancar_dialogo() -> void:
	if _digitando:
		# Se o jogador apertar enquanto ainda está digitando, pula direto para o texto completo
		if is_instance_valid(_tween_texto):
			_tween_texto.kill()
		_ao_terminar_digitacao()
	else:
		# Se já terminou de digitar a frase atual, avança para a próxima
		_indice_fala += 1
		_exibir_fala_atual()


func _concluir_dialogo() -> void:
	# 1. Caixa de diálogo desaparece com animação suave
	var tween_saida: Tween = create_tween()
	tween_saida.tween_property(painel_dialogo, "modulate:a", 0.0, 0.2)
	tween_saida.tween_callback(func() -> void:
		painel_dialogo.visible = false
	)

	# 2. Professora volta para idle
	_definir_animacao_professora("idle")

	# 3. Jogador é desbloqueado para explorar o museu
	_definir_bloqueio_jogador(false)

	dialogo_finalizado.emit()


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
