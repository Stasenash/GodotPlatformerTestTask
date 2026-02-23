extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var animation = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			animation.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animation.play("Idle")
		
	if direction == -1:
		animation.flip_h = true
	elif direction == 1:
		animation.flip_h = false

	if velocity.y > 0:
		animation.play("Fall")

	move_and_slide()
