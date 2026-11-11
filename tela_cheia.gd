extends CheckButton
## Botão de alternância de tela cheia com feedback visual e sonoro.

const SOM_CONFIRMAR: AudioStream = preload("res://audios/ui/menu_confirmar.ogg")

var _player_sfx: AudioStreamPlayer


func _ready() -> void:
	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.bus = &"efeitos"
	_player_sfx.stream = SOM_CONFIRMAR
	add_child(_player_sfx)
	set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_toggled(toggled_on: bool) -> void:
	if is_instance_valid(_player_sfx):
		_player_sfx.pitch_scale = 1.05 if toggled_on else 0.95
		_player_sfx.play()

	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
