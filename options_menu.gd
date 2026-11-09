extends Control

signal exit_options_menu

func _ready():
	pass

func _process(delta):
	pass

func _on_back_pressed() -> void:
	exit_options_menu.emit()
