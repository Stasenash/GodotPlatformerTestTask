extends CharacterBody2D


const MOVE_SPEED: float = 300.0
const JUMP_FORCE: float = -550.0
const ATTACK_DAMAGE: int = 15
const ATTACK_OFFSET: float = 30.0


signal health_changed(current: int, max: int)
signal died


@export var max_health: int = 100
var health: int


enum State {
	SPAWN,
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	HIT,
	DEAD
}

var state: State = State.SPAWN


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea


func _ready() -> void:
	health = max_health
	emit_signal("health_changed", health, max_health)

	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)

	anim.animation_finished.connect(_on_animation_finished)

	_enter_spawn()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_apply_gravity(delta)
	_handle_input()
	_update_state()
	move_and_slide()
	_update_animation()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_input() -> void:
	if state in [State.ATTACK, State.SPAWN, State.HIT]:
		return

	if Input.is_action_just_pressed("attack"):
		_change_state(State.ATTACK)
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if direction != 0:
		_update_orientation(direction)


func _update_state() -> void:
	if state in [State.ATTACK, State.SPAWN, State.HIT]:
		return

	if not is_on_floor():
		state = State.JUMP if velocity.y < 0 else State.FALL
	elif velocity.x != 0:
		state = State.RUN
	else:
		state = State.IDLE


func _change_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.SPAWN:
			_enter_spawn()
		State.ATTACK:
			_enter_attack()
		State.HIT:
			_enter_hit()
		State.DEAD:
			_enter_dead()



func _enter_spawn() -> void:
	velocity = Vector2.ZERO
	_play_animation("Spawn")


func _enter_attack() -> void:
	velocity.x = 0.0
	_play_animation("Attack")
	_enable_attack()


func _enter_hit() -> void:
	velocity.x = 0.0
	_play_animation("Damage")


func _enter_dead() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	_play_animation("Defeat")
	emit_signal("died")



func _enable_attack() -> void:
	attack_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false


func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(ATTACK_DAMAGE)



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
		State.ATTACK, State.SPAWN, State.HIT, State.DEAD:
			pass


func _play_animation(name: String) -> void:
	if anim.animation != name:
		anim.play(name)


func _on_animation_finished() -> void:
	match state:
		State.ATTACK:
			_change_state(State.IDLE)
		State.SPAWN:
			_change_state(State.IDLE)
		State.HIT:
			_change_state(State.IDLE)



func _update_orientation(direction: float) -> void:
	anim.flip_h = direction < 0
	attack_area.position.x = -ATTACK_OFFSET if anim.flip_h else 0



func take_damage(amount: int) -> void:
	if state in [State.SPAWN, State.HIT, State.DEAD]:
		return

	health = clamp(health - amount, 0, max_health)
	emit_signal("health_changed", health, max_health)

	if health == 0:
		_change_state(State.DEAD)
	else:
		_change_state(State.HIT)



func respawn(position: Vector2) -> void:
	global_position = position
	health = max_health
	emit_signal("health_changed", health, max_health)
	set_physics_process(true)
	_change_state(State.SPAWN)
