extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -550.0


enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	SPAWN
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var state: State = State.SPAWN


func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	_play_animation("Spawn")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_input()
	_update_state()
	_update_animation()
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_input() -> void:
	if state == State.ATTACK or state == State.SPAWN:
		return

	if Input.is_action_just_pressed("attack"):
		_change_state(State.ATTACK)
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	if direction != 0:
		anim.flip_h = direction < 0


func respawn(gp: Vector2) -> void:
	global_position = gp
	velocity = Vector2.ZERO
	_change_state(State.SPAWN)
	_play_animation("Spawn")

func _update_state() -> void:
	if state == State.ATTACK or state == State.SPAWN:
		return

	if not is_on_floor():
		state = State.JUMP if velocity.y < 0 else State.FALL
	elif velocity.x != 0:
		state = State.RUN
	else:
		state = State.IDLE


func _change_state(new_state: State) -> void:
	state = new_state


func _update_animation() -> void:
	match state:
		State.IDLE:
			_play_animation("Idle")
		State.RUN:
			_play_animation("Walk")
		State.JUMP:
			_play_animation("Jump")
		State.FALL:
			_play_animation("Fall")
		State.ATTACK:
			_play_animation("Attack")


func _play_animation(name: String) -> void:
	if anim.animation != name:
		anim.play(name)


func _on_animation_finished() -> void:
	if state == State.ATTACK or state == State.SPAWN:
		_change_state(State.IDLE)
