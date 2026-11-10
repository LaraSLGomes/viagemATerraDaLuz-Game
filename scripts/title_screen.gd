extends Control

@onready var options_menu = $options_menu
@onready var menu_container = $MenuContainer
@onready var background = $VideoBackground
@onready var start_button: Button = find_child("BotaoNovoJogo", true, false) as Button

func _ready():
	if not Engine.is_editor_hint():
		background.visible = true
		background.play()
		if is_instance_valid(start_button):
			start_button.grab_focus()
		else:
			push_warning("BotaoNovoJogo não foi encontrado na cena da tela inicial.")

func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://cenas/lobby_scene.tscn")

func _on_option_btn_pressed():
	menu_container.visible = false
	options_menu.visible = true

func _on_quit_btn_pressed():
	get_tree().quit()

# Esta é a função que o botão "Voltar" do menu de opções está chamando
func _on_options_menu_exit_options_menu() -> void:
	options_menu.visible = false
	menu_container.visible = true
