extends CanvasLayer

const KILLS_TEXT_FORMAT: String = "Enemies killed: %d"
const HP_TEXT_FORMAT: String = "%d / %d"

@onready var _hp_bar: ProgressBar = $MarginContainer/HBoxContainer/HPContainer/HPBar
@onready var _kills_label: Label = $MarginContainer/HBoxContainer/KillsCounter
@onready var _hp_text: Label = $MarginContainer/HBoxContainer/HPContainer/HPBar/HPText

var _max_health: int = 100


func set_max_health(value: int) -> void:
	_max_health = max(value, 1)
	_hp_bar.max_value = _max_health
	_update_health_visual(_hp_bar.value)


func update_health(current: int) -> void:
	var clamped_value: int = clamp(current, 0, _max_health)
	_update_health_visual(clamped_value)


func update_kills(count: int) -> void:
	_kills_label.text = KILLS_TEXT_FORMAT % count


# ================= Internal =================

func _update_health_visual(current: int) -> void:
	_hp_bar.value = current
	_hp_text.text = HP_TEXT_FORMAT % [current, _max_health]
