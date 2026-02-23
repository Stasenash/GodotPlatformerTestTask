extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/HBoxContainer/HPBar
@onready var kills_counter: Label = $MarginContainer/HBoxContainer/KillsCounter


var max_health: int = 100


func set_max_health(value: int) -> void:
	max_health = value
	hp_bar.max_value = value


func update_health(current: int) -> void:
	hp_bar.value = current


func update_kills(count: int) -> void:
	kills_counter.text = "Enemies killed: %d" % count
