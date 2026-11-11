extends CharacterBody2D
## Controlador top-down do protagonista no Museu/Puzzle com Game Feel, partículas e tremor de câmera.

signal interagiu_puzzle(posicao_global: Vector2)

const SPEED: float = 500.0
const ACELERACAO: float = 2600.0
const ATRITO: float = 3000.0
const INTERVALO_PASSO: float = 0.28

const SONS_PASSOS: Array[AudioStream] = [
	preload("res://audios/personagem/passo_1.ogg"),
	preload("res://audios/personagem/passo_2.ogg"),
	preload("res://audios/personagem/passo_3.ogg"),
]
const SOM_INTERAGIR: AudioStream = preload("res://audios/personagem/interagir.ogg")

var last_direction: Vector2 = Vector2.DOWN
var _estava_em_movimento: bool = false
var _timer_passo: float = 0.0
var _cooldown_colisao: float = 0.0
var _tween_sprite: Tween
var _tween_camera: Tween
var _player_sfx: AudioStreamPlayer2D

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = get_node_or_null("Camera2D") as Camera2D
@onready var poeira_passos: CPUParticles2D = get_node_or_null("PoeiraPassos") as CPUParticles2D


func _ready() -> void:
	_player_sfx = AudioStreamPlayer2D.new()
	_player_sfx.bus = &"efeitos"
	add_child(_player_sfx)


func _physics_process(delta: float) -> void:
	if _cooldown_colisao > 0.0:
		_cooldown_colisao -= delta

	process_movement(delta)
	var velocidade_antes: float = velocity.length()
	var colidiu: bool = move_and_slide()
	process_animation(delta)

	if colidiu and velocidade_antes > SPEED * 0.65 and _cooldown_colisao <= 0.0:
		_cooldown_colisao = 0.35
		aplicar_tremor_camera(2.8, 0.16)
		_animar_squash_stretch(Vector2(1.12, 0.88), 0.14)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
		interagir_no_cenario()


## Executa feedback visual e tremor de câmera ao interagir com quadros ou elementos do puzzle.
func interagir_no_cenario() -> void:
	_tocar_sfx(SOM_INTERAGIR, 0.98, 1.05)
	aplicar_tremor_camera(4.2, 0.22)
	_animar_squash_stretch(Vector2(1.18, 0.84), 0.18)
	interagiu_puzzle.emit(global_position)


## Aplica um leve tremor amortecido na Camera2D usando Tween para feedback em puzzles e portais.
func aplicar_tremor_camera(intensidade: float = 3.5, duracao: float = 0.2) -> void:
	if not is_instance_valid(camera):
		return

	if is_instance_valid(_tween_camera):
		_tween_camera.kill()

	_tween_camera = create_tween()
	var passos: int = 5
	var tempo_passo: float = duracao / float(passos)
	for i: int in range(passos - 1):
		var fator: float = 1.0 - (float(i) / float(passos))
		var deslocamento := Vector2(
			randf_range(-intensidade, intensidade) * fator,
			randf_range(-intensidade, intensidade) * fator
		)
		_tween_camera.tween_property(camera, "offset", deslocamento, tempo_passo).set_trans(Tween.TRANS_SINE)

	_tween_camera.tween_property(camera, "offset", Vector2.ZERO, tempo_passo).set_trans(Tween.TRANS_SINE)


func process_movement(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * SPEED, ACELERACAO * delta)
		last_direction = direction
		if not _estava_em_movimento:
			_estava_em_movimento = true
			_animar_squash_stretch(Vector2(0.92, 1.08), 0.12)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ATRITO * delta)
		if _estava_em_movimento and velocity.length() < 20.0:
			_estava_em_movimento = false
			_animar_squash_stretch(Vector2(1.06, 0.94), 0.12)


func process_animation(delta: float) -> void:
	var em_movimento: bool = velocity.length() > 25.0

	if is_instance_valid(poeira_passos):
		poeira_passos.emitting = em_movimento

	if em_movimento:
		play_animation("walk", last_direction)
		_timer_passo -= delta
		if _timer_passo <= 0.0:
			_timer_passo = INTERVALO_PASSO
			var indice: int = randi() % SONS_PASSOS.size()
			_tocar_sfx(SONS_PASSOS[indice], 0.92, 1.08)
	else:
		play_animation("idle", last_direction)
		_timer_passo = 0.05


func play_animation(prefix: String, dir: Vector2) -> void:
	if not is_instance_valid(anima):
		return
	if absf(dir.x) >= absf(dir.y):
		if dir.x > 0.0:
			anima.flip_h = false
			anima.play(prefix + "_right")
		elif dir.x < 0.0:
			anima.flip_h = true
			anima.play(prefix + "_right")
	else:
		if dir.y < 0.0:
			anima.play(prefix + "_up")
		elif dir.y > 0.0:
			anima.play(prefix + "_down")


func _animar_squash_stretch(escala_pico: Vector2, duracao: float) -> void:
	if not is_instance_valid(anima):
		return
	if is_instance_valid(_tween_sprite):
		_tween_sprite.kill()

	_tween_sprite = create_tween()
	_tween_sprite.tween_property(anima, "scale", escala_pico, duracao * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_sprite.tween_property(anima, "scale", Vector2.ONE, duracao * 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _tocar_sfx(stream: AudioStream, pitch_min: float = 0.95, pitch_max: float = 1.05) -> void:
	if is_instance_valid(_player_sfx) and stream != null:
		_player_sfx.stream = stream
		_player_sfx.pitch_scale = randf_range(pitch_min, pitch_max)
		_player_sfx.play()
