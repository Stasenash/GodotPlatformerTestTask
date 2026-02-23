extends Control

class_name MeinMenu

@onready var play_button: Button = $ButtonsContainer/PlayButton
@onready var exit_button: Button = $ButtonsContainer/ExitButton



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
