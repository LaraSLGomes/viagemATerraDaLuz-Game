extends CharacterBody2D

const SPEED = 500.0
var last_direction: Vector2 = Vector2.RIGHT

@onready var anima = $AnimatedSprite2D

func _physics_process(_delta) -> void:
	move_and_slide()
	process_animation()
	process_movement()

# ------------------------- MOVEMENT --------------------- #

func process_movement() -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	if velocity != Vector2.ZERO:
		play_animation("walk", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0:
		anima.flip_h = false
		anima.play((prefix + "_right"))
	elif dir.x < 0:
		anima.flip_h = true
		anima.play((prefix + "_right"))
	elif dir.y < 0:
		anima.play((prefix + "_up"))
	elif dir.y > 0:
		anima.play((prefix + "_down"))
