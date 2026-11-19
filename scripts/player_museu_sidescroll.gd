extends CharacterBody2D
## Controlador do jogador no Museu (Side-scroller 2D com física de gravidade, pulo e passos)

const SPEED: float = 340.0
const JUMP_VELOCITY: float = -520.0
const GRAVIDADE: float = 1200.0

var bloqueado: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var poeira_passos: CPUParticles2D = get_node_or_null("PoeiraPassos") as CPUParticles2D
var avatar_visual: AvatarVisual = null


func _ready() -> void:
	add_to_group("player")
	
	# Instancia o AvatarVisual modular e customizado
	var cena_avatar: PackedScene = load("res://cenas/AvatarVisual.tscn")
	if cena_avatar:
		avatar_visual = cena_avatar.instantiate() as AvatarVisual
		# Escala proporcional para encaixar na colisão do Player (180x360 -> ~180px de altura)
		avatar_visual.scale = Vector2(0.56, 0.56)
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

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento horizontal
	var direction: float = Input.get_axis("left", "right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		if is_instance_valid(avatar_visual):
			avatar_visual.definir_espelhamento(direction < 0.0)
		elif is_instance_valid(animated_sprite):
			animated_sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 0.2)

	move_and_slide()
	_atualizar_animacao()


func _atualizar_animacao() -> void:
	var em_movimento: bool = abs(velocity.x) > 10.0 and is_on_floor()
	
	if is_instance_valid(avatar_visual):
		avatar_visual.definir_animacao_andando(em_movimento)
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
