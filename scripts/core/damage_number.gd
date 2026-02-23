extends Node2D

@export var float_speed: float = 40.0
@export var lifetime: float = 0.6

@onready var label: Label = $Damage

var time_passed: float = 0.0


func setup(amount: int, color: Color = Color.RED) -> void:
	label.text = str(amount)
	label.modulate = color


func _process(delta: float) -> void:
	time_passed += delta

	position.y -= float_speed * delta

	# плавное исчезновение
	var alpha := 1.0 - (time_passed / lifetime)
	label.modulate.a = clamp(alpha, 0.0, 1.0)

	if time_passed >= lifetime:
		queue_free()
