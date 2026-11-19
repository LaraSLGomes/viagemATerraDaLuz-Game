extends CharacterBody2D
## Controlador do jogador no Museu (Side-scroller 2D com física de gravidade, pulo e passos)

const SPEED: float = 340.0
const RUN_SPEED: float = 500.0
const JUMP_VELOCITY: float = -520.0
const GRAVIDADE: float = 1200.0

var bloqueado: bool = false
var esta_agachado: bool = false
var esta_escrevendo: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var poeira_passos: CPUParticles2D = get_node_or_null("PoeiraPassos") as CPUParticles2D
var avatar_visual: AvatarVisual = null


func _ready() -> void:
	add_to_group("player")
	
	# Instancia o AvatarVisual modular e customizado
	var cena_avatar: PackedScene = load("res://cenas/AvatarVisual.tscn")
	if cena_avatar:
		avatar_visual = cena_avatar.instantiate() as AvatarVisual
		# Escala proporcional para encaixar na colisão do Player (300x450 -> ~180px de altura)
		avatar_visual.scale = Vector2(0.48, 0.48)
		# Centraliza na cápsula de colisão
		avatar_visual.position = Vector2(0, 5)
		add_child(avatar_visual)
		avatar_visual.carregar_do_global()
		
		# Se instanciou com sucesso, oculta o AnimatedSprite2D legado
		if is_instance_valid(animated_sprite):
			animated_sprite.visible = false
	else:
		# Fallback legado caso não encontre a cena
		if is_instance_valid(animated_sprite):
			if animated_sprite.sprite_frames.has_animation("personagem parado"):
				animated_sprite.play("personagem parado")


func _physics_process(delta: float) -> void:
	# Gravidade contínua
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	# Se estiver bloqueado (durante diálogo da professora), cancela input
	if bloqueado:
		velocity.x = 0.0
		move_and_slide()
		_atualizar_animacao()
		return

	# Gatilhos de Ação (run, jump, crouch, pickup, write)
	var quer_correr: bool = Input.is_action_pressed("run") or Input.is_key_pressed(KEY_SHIFT)
	var vel_atual: float = RUN_SPEED if quer_correr else SPEED
	
	if Input.is_action_just_pressed("crouch") or Input.is_key_pressed(KEY_C):
		esta_agachado = !esta_agachado
		if esta_agachado and is_instance_valid(avatar_visual):
			avatar_visual.tocar_animacao("crouch")
	
	if Input.is_action_just_pressed("write") or Input.is_key_pressed(KEY_E):
		esta_escrevendo = !esta_escrevendo
		if esta_escrevendo and is_instance_valid(avatar_visual):
			avatar_visual.tocar_animacao("write")

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		esta_agachado = false
		esta_escrevendo = false
		if is_instance_valid(avatar_visual):
			avatar_visual.tocar_animacao("jump")

	# Movimento horizontal
	var direction: float = Input.get_axis("left", "right")
	if direction != 0.0:
		esta_agachado = false
		esta_escrevendo = false
		velocity.x = direction * vel_atual
		if is_instance_valid(avatar_visual):
			avatar_visual.definir_espelhamento(direction < 0.0)
		elif is_instance_valid(animated_sprite):
			animated_sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, vel_atual * 0.2)

	move_and_slide()
	_atualizar_animacao()


func _atualizar_animacao() -> void:
	var em_movimento: bool = abs(velocity.x) > 10.0 and is_on_floor()
	var correndo: bool = abs(velocity.x) > 360.0 and is_on_floor()

	if is_instance_valid(avatar_visual):
		if not is_on_floor():
			avatar_visual.tocar_animacao("jump")
		elif correndo:
			avatar_visual.tocar_animacao("run")
		elif em_movimento:
			avatar_visual.tocar_animacao("walk_side")
		elif not esta_agachado and not esta_escrevendo:
			avatar_visual.tocar_animacao("idle")
		
		if is_instance_valid(poeira_passos):
			poeira_passos.emitting = em_movimento
		return

	if not is_instance_valid(animated_sprite):
		return

	if not is_on_floor():
		if animated_sprite.sprite_frames.has_animation("personagem pulando"):
			animated_sprite.play("personagem pulando")
	elif em_movimento:
		if animated_sprite.sprite_frames.has_animation("personagem andando"):
			animated_sprite.play("personagem andando")
		if is_instance_valid(poeira_passos):
			poeira_passos.emitting = true
	else:
		if animated_sprite.sprite_frames.has_animation("personagem parado"):
			animated_sprite.play("personagem parado")
		if is_instance_valid(poeira_passos):
			poeira_passos.emitting = false


func executar_acao(acao: String) -> void:
	if not is_instance_valid(avatar_visual):
		return
	match acao:
		"pickup":
			avatar_visual.tocar_animacao("pickup")
		"crouch":
			avatar_visual.tocar_animacao("crouch")
		"jump":
			avatar_visual.tocar_animacao("jump")
		"write":
			avatar_visual.tocar_animacao("write")
		"run":
			avatar_visual.tocar_animacao("run")
		"walk_front":
			avatar_visual.tocar_animacao("walk_front")
		"walk_three_quarter":
			avatar_visual.tocar_animacao("walk_three_quarter")
		"walk_side":
			avatar_visual.tocar_animacao("walk_side")
		"idle":
			avatar_visual.tocar_animacao("idle")
