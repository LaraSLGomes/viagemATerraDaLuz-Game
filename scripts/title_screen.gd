extends Control

@onready var options_menu = $options_menu
@onready var margin_container = $MarginContainer

func _ready():
	pass

func _process(delta):
	pass

func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://cenas/lobby_scene.tscn")

func _on_option_btn_pressed():
	margin_container.visible = false
	options_menu.visible = true

func _on_quit_btn_pressed():
	get_tree().quit()

# Esta é a função que o botão "Voltar" do menu de opções está chamando
func _on_options_menu_exit_options_menu() -> void:
	options_menu.visible = false
	margin_container.visible = true
