extends CharacterBody2D


const BASE_SPEED: float = 100.0
const CHASE_SPEED_MULT: float = 2.0
const ATTACK_DISTANCE: float = 100.0
const ATTACK_DAMAGE: int = 3
const ATTACK_OFFSET: float = 30.0
const DAMAGE_NUMBER_SCENE := preload("res://scenes/ui/damage_number.tscn")

signal died

@export var max_health: int = 10
var health: int


enum State {
	PATROL,
	CHASE,
	ATTACK,
	HIT,
	DEAD
}

var state: State = State.PATROL
var direction: int = 1
var player_in_range: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_area: Area2D = $AttackArea
@onready var left_ray: RayCast2D = $LeftEdgeRay
@onready var right_ray: RayCast2D = $RightEdgeRay
@onready var player: CharacterBody2D = get_parent().get_node("Player")


func _ready() -> void:
	health = max_health
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_body_entered)
	animation_player.animation_finished.connect(_on_anim_player_finished)


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_apply_gravity(delta)
	_process_ai()
	_update_movement()
	move_and_slide()
	_update_animation()


func _process_ai() -> void:
	if state in [State.ATTACK, State.HIT, State.DEAD]:
		return
	if player_in_range:
		if _is_player_close():
			_change_state(State.ATTACK)
		elif state != State.HIT:
			_change_state(State.CHASE)
	else:
		_change_state(State.PATROL)


func _is_player_close() -> bool:
	return abs(player.global_position.x - global_position.x) < ATTACK_DISTANCE


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _update_movement() -> void:
	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
		State.ATTACK, State.HIT:
			velocity.x = 0.0
		State.DEAD:
			velocity = Vector2.ZERO


func _patrol() -> void:
	velocity.x = direction * BASE_SPEED

	if direction == 1 and not right_ray.is_colliding():
		_flip()
	elif direction == -1 and not left_ray.is_colliding():
		_flip()

	_update_orientation(direction)


func _chase() -> void:
	var delta_x: float = player.global_position.x - global_position.x
	var dir_x: int = signi(delta_x)

	velocity.x = dir_x * BASE_SPEED * CHASE_SPEED_MULT

	if dir_x != 0:
		_update_orientation(dir_x)


func _flip() -> void:
	direction *= -1


func _update_orientation(dir: int) -> void:
	anim.flip_h = dir < 0
	attack_area.position.x = -ATTACK_OFFSET if anim.flip_h else 0.0



func _change_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.ATTACK:
			_enter_attack()
		State.HIT:
			_enter_hit()
		State.DEAD:
			_enter_dead()


func _enter_attack() -> void:
	velocity.x = 0.0
	animation_player.play("Attack")


func _enter_hit() -> void:
	velocity.x = 0.0
	animation_player.play("Hit")


func _enter_dead() -> void:
	emit_signal("died")
	velocity = Vector2.ZERO
	animation_player.play("Defeat")


func _enable_attack() -> void:
	attack_area.monitoring = true


func _disable_attack() -> void:
	attack_area.monitoring = false


func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(ATTACK_DAMAGE)



func _update_animation() -> void:
	match state:
		State.PATROL:
			_play_animation("Walk")
		State.CHASE:
			_play_animation("WalkFaster")
		State.ATTACK, State.HIT, State.DEAD:
			pass


func _play_animation(name: String) -> void:
	if anim.animation != name:
		anim.play(name)


func _on_anim_player_finished(anim_name: StringName) -> void:
	match anim_name:
		"Attack":
			_disable_attack()
			if player_in_range:
				_change_state(State.CHASE)
			else:
				_change_state(State.PATROL)

		"Hit":
			if player_in_range:
				_change_state(State.CHASE)
			else:
				_change_state(State.PATROL)
		
		"Defeat":
			queue_free()


func _is_player_visible() -> bool:
	return player_in_range

func take_damage(amount: int) -> void:
	if state in [State.DEAD, State.HIT]:
		return

	_spawn_damage_number(amount)

	health = clamp(health - amount, 0, max_health)

	if health == 0:
		_change_state(State.DEAD)
	else:
		_change_state(State.HIT)

func _spawn_damage_number(amount: int) -> void:
	var dmg = DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(dmg)

	dmg.global_position = global_position + Vector2(0, -40)
	dmg.setup(amount)

func _on_detector_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true
		if state not in [State.DEAD, State.ATTACK, State.HIT]:
			_change_state(State.CHASE)


func _on_detector_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false
		if state not in [State.DEAD, State.ATTACK, State.HIT]:
			_change_state(State.PATROL)
