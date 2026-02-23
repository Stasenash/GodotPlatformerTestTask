extends CharacterBody2D


const MOVE_SPEED: float = 300.0
const JUMP_FORCE: float = -550.0
const ATTACK_DAMAGE: int = 4
const ATTACK_OFFSET: float = 35.0
const ATTACK_COOLDOWN: float = 1.5
const ATTACK_ACTIVE_TIME: float = 0.2

const DAMAGE_NUMBER_SCENE := preload("res://scenes/ui/damage_number.tscn")

signal health_changed(current: int, max: int)
signal died


@export var max_health: int = 20
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
var attack_timer: float = 0.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _attack_area: Area2D = $AttackArea


func _ready() -> void:
	health = max_health
	emit_signal("health_changed", health, max_health)

	_attack_area.monitoring = false
	_attack_area.body_entered.connect(_on_attack_body_entered)
	_anim.animation_finished.connect(_on_animation_finished)

	_enter_spawn()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_update_attack_cooldown(delta)
	_apply_gravity(delta)
	_handle_input()
	_update_state()

	move_and_slide()
	_update_animation()


# ================= Core =================

func _update_attack_cooldown(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# ================= Input =================

func _handle_input() -> void:
	if state in [State.ATTACK, State.SPAWN, State.HIT]:
		return

	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		_change_state(State.ATTACK)
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if direction != 0.0:
		_update_orientation(direction)


# ================= State Update =================

func _update_state() -> void:
	if state in [State.ATTACK, State.SPAWN, State.HIT]:
		return

	if not is_on_floor():
		_change_state(State.JUMP if velocity.y < 0 else State.FALL)
	elif velocity.x != 0.0:
		_change_state(State.RUN)
	else:
		_change_state(State.IDLE)


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


# ================= Enter States =================

func _enter_spawn() -> void:
	velocity = Vector2.ZERO
	_play_animation("Spawn")


func _enter_attack() -> void:
	velocity.x = 0.0
	_play_animation("Attack")
	_start_attack_window()


func _enter_hit() -> void:
	velocity.x = 0.0
	_play_animation("Damage")


func _enter_dead() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	_play_animation("Defeat")
	died.emit()


# ================= Attack =================

func _start_attack_window() -> void:
	_attack_area.monitoring = true
	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	_attack_area.monitoring = false


func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(ATTACK_DAMAGE)


# ================= Animation =================

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
	if _anim.animation != name:
		_anim.play(name)


func _on_animation_finished() -> void:
	match state:
		State.ATTACK:
			attack_timer = ATTACK_COOLDOWN
			_change_state(State.IDLE)
		State.SPAWN:
			_change_state(State.IDLE)
		State.HIT:
			_change_state(State.IDLE)


# ================= Orientation =================

func _update_orientation(direction: float) -> void:
	_anim.flip_h = direction < 0.0
	_attack_area.position.x = -ATTACK_OFFSET if _anim.flip_h else 0.0


# ================= Damage =================

func take_damage(amount: int) -> void:
	if state in [State.SPAWN, State.HIT, State.DEAD]:
		return

	_spawn_damage_number(amount)

	health = clamp(health - amount, 0, max_health)
	health_changed.emit(health, max_health)

	if health == 0:
		_change_state(State.DEAD)
	else:
		_change_state(State.HIT)


func _spawn_damage_number(amount: int) -> void:
	var dmg = DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(dmg)

	dmg.global_position = global_position + Vector2(0, -50)
	dmg.setup(amount, Color(1.0, 0.3, 0.3))


# ================= Respawn =================

func respawn(position: Vector2) -> void:
	global_position = position
	set_physics_process(true)
	health_changed.emit(health, max_health)
	_change_state(State.SPAWN)
