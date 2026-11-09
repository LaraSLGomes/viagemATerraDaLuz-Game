extends Control

@onready var options_menu = $options_menu
@onready var margin_container = $MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu.exit_options_menu.connect(on_exit_options_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://cenas/lobby_scene.tscn")


func _on_option_btn_pressed():
	margin_container.visible = false
	options_menu.visible = true


func _on_quit_btn_pressed():
	get_tree().quit()
	
func on_exit_options_menu() -> void:
	options_menu.visible = false
	margin_container.visible = true
