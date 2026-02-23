extends CharacterBody2D

const SPEED: float = 100.0

enum State {
	IDLE,
	CHASE,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_parent().get_node("Player")

var state: State = State.IDLE


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_apply_gravity(delta)
	_update_state()
	_update_movement()
	_update_animation()

	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta



func _update_state() -> void:
	if state == State.DEAD:
		return
	# IDLE и CHASE переключаются через detector
	pass


func _change_state(new_state: State) -> void:
	state = new_state


func _update_movement() -> void:
	if state != State.CHASE:
		velocity.x = 0
		return

	var direction := (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED

	if direction.x != 0:
		anim.flip_h = direction.x < 0



func _update_animation() -> void:
	match state:
		State.IDLE:
			_play_animation("Idle")
		State.CHASE:
			_play_animation("Walk")
		State.DEAD:
			_play_animation("Death")


func _play_animation(name: String) -> void:
	if anim.animation != name:
		anim.play(name)



func _on_detector_body_entered(body: Node2D) -> void:
	if body == player:
		_change_state(State.CHASE)


func _on_detector_body_exited(body: Node2D) -> void:
	if body == player:
		_change_state(State.IDLE)


func die() -> void:
	_change_state(State.DEAD)
	velocity = Vector2.ZERO
