extends CanvasLayer

signal restart_requested
signal menu_requested

const TEXT_VICTORY: String = "VICTORY"
const TEXT_DEFEAT: String = "DEFEAT"

@onready var _win_lose_label: Label = $Control/WinLose
@onready var _kills_label: Label = $Control/EnemiesKilled
@onready var _restart_button: Button = $Control/VBoxContainer/RestartButton
@onready var _menu_button: Button = $Control/VBoxContainer/MenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_restart_button.pressed.connect(_on_restart_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func show_result(is_win: bool, kills: int) -> void:
	visible = true
	get_tree().paused = true

	_set_result_text(is_win)
	_set_kills_text(kills)


func hide_screen() -> void:
	get_tree().paused = false
	visible = false


# ================= UI Update =================

func _set_result_text(is_win: bool) -> void:
	_win_lose_label.text = TEXT_VICTORY if is_win else TEXT_DEFEAT


func _set_kills_text(kills: int) -> void:
	_kills_label.text = "Enemies killed: %d" % kills


# ================= Buttons =================

func _on_restart_pressed() -> void:
	hide_screen()
	restart_requested.emit()


func _on_menu_pressed() -> void:
	hide_screen()
	menu_requested.emit()
