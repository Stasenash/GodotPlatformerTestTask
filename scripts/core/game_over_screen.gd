extends CanvasLayer

signal restart_requested
signal menu_requested

@onready var win_lose_label: Label = $Control/WinLose
@onready var kills_label: Label = $Control/EnemiesKilled
@onready var restart_button: Button = $Control/VBoxContainer/RestartButton
@onready var menu_button: Button = $Control/VBoxContainer/MenuButton
@onready var win_lose: Label = $Control/WinLose


func _ready() -> void:
	visible = false


func show_result(is_win: bool, kills: int) -> void:
	visible = true
	get_tree().paused = true

	_update_result_text(is_win)
	kills_label.text = "Enemies killed: %d" % kills

func _update_result_text(is_win: bool) -> void:
	if is_win:
		win_lose_label.text = "VICTORY"
	else:
		win_lose_label.text = "DEFEAT"

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	emit_signal("restart_requested")


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	emit_signal("menu_requested")
