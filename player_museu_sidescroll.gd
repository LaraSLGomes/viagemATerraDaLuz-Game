extends CharacterBody2D
## Controlador do jogador no Museu (Side-scroller 2D com física de gravidade, pulo e passos)

const SPEED: float = 340.0
const JUMP_VELOCITY: float = -520.0
const GRAVIDADE: float = 1200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D as AnimatedSprite2D
@onready var poeira_passos: CPUParticles2D = get_node_or_null("PoeiraPassos") as CPUParticles2D


func _ready() -> void:
	# Ajusta sprite/cor de acordo com a seleção no Global
	if Engine.has_singleton("Global") or has_node("/root/Global"):
		var g: Node = get_node("/root/Global")
		if is_instance_valid(animated_sprite) and "cor_roupa" in g:
			animated_sprite.modulate = g.cor_pele.lerp(Color.WHITE, 0.4)


func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento horizontal
	var direction: float = Input.get_axis("left", "right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		if is_instance_valid(animated_sprite):
			animated_sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 0.2)

	move_and_slide()
	_atualizar_animacao()


func _atualizar_animacao() -> void:
	if not is_instance_valid(animated_sprite):
		return

	if not is_on_floor():
		if animated_sprite.sprite_frames.has_animation("personagem pulando"):
			animated_sprite.play("personagem pulando")
	elif abs(velocity.x) > 10.0:
		if animated_sprite.sprite_frames.has_animation("personagem andando"):
			animated_sprite.play("personagem andando")
		if is_instance_valid(poeira_passos):
			poeira_passos.emitting = true
	else:
		if animated_sprite.sprite_frames.has_animation("personagem parado"):
			animated_sprite.play("personagem parado")
		if is_instance_valid(poeira_passos):
			poeira_passos.emitting = false
