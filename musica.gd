extends HSlider
## Controle deslizante de volume para um barramento de áudio (AudioServer) com pulso visual.

@export var audio_bus_name: String = "Master"

var audio_bus_id: int = -1
var _tween_pulso: Tween


func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	pivot_offset = size * 0.5
	if audio_bus_id >= 0:
		set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id)))


func _on_value_changed(valor: float) -> void:
	if audio_bus_id < 0:
		audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id >= 0:
		var db: float = linear_to_db(maxf(valor, 0.0001))
		AudioServer.set_bus_volume_db(audio_bus_id, db)
		AudioServer.set_bus_mute(audio_bus_id, valor <= 0.001)

	pivot_offset = size * 0.5
	if is_instance_valid(_tween_pulso):
		_tween_pulso.kill()
	_tween_pulso = create_tween()
	_tween_pulso.tween_property(self, "scale", Vector2(1.03, 1.08), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_pulso.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
