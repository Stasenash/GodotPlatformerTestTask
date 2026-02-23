extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/HBoxContainer/HPContainer/HPBar
@onready var kills_counter: Label = $MarginContainer/HBoxContainer/KillsCounter
@onready var hp_text: Label = $MarginContainer/HBoxContainer/HPContainer/HPBar/HPText


var max_health: int = 100


func set_max_health(value: int) -> void:
	max_health = value
	hp_bar.max_value = value
	_update_hp_text(hp_bar.value)

func update_health(current: int) -> void:
	hp_bar.value = current
	_update_hp_text(hp_bar.value)

func update_kills(count: int) -> void:
	kills_counter.text = "Enemies killed: %d" % count

func _update_hp_text(current: int) -> void:
	hp_text.text = "%d / %d" % [current, max_health]
