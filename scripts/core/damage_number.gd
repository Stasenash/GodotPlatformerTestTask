extends Node2D

@export var float_speed: float = 40.0
@export var lifetime: float = 0.6

@onready var _label: Label = $Damage

var _elapsed: float = 0.0


func setup(amount: int, color: Color = Color.RED) -> void:
	_label.text = str(amount)
	_label.modulate = color


func _process(delta: float) -> void:
	_elapsed += delta

	_update_position(delta)
	_update_fade()

	if _is_expired():
		queue_free()


func _update_position(delta: float) -> void:
	position.y -= float_speed * delta


func _update_fade() -> void:
	if lifetime <= 0.0:
		return

	var progress: float = clamp(_elapsed / lifetime, 0.0, 1.0)
	_label.modulate.a = 1.0 - progress


func _is_expired() -> bool:
	return _elapsed >= lifetime
