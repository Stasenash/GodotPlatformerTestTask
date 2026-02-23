extends CharacterBody2D

const SPEED: float = 100.0
const CHASE_SPEED_MULT: float = 2.0

enum State {
	PATROL,
	CHASE,
	DEAD
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_parent().get_node("Player")
@onready var left_ray: RayCast2D = $LeftEdgeRay
@onready var right_ray: RayCast2D = $RightEdgeRay


var state: State = State.PATROL
var direction: int = 1   # 1 = вправо, -1 = влево

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
	# PATROL и CHASE переключаются через detector
	pass

func _change_state(new_state: State) -> void:
	state = new_state


func _update_movement() -> void:
	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
		State.DEAD:
			velocity = Vector2.ZERO
	

func _patrol() -> void:
	velocity.x = direction * SPEED

	# Проверка края платформы
	if direction == 1 and not right_ray.is_colliding():
		_flip()
	elif direction == -1 and not left_ray.is_colliding():
		_flip()

	anim.flip_h = direction < 0


func _chase() -> void:
	var to_player := player.global_position - global_position
	var dir_x: int = 0

	if to_player.x > 0:
		dir_x = 1
	elif to_player.x < 0:
		dir_x = -1

	velocity.x = dir_x * SPEED * CHASE_SPEED_MULT

	if dir_x != 0:
		anim.flip_h = dir_x < 0

func _flip() -> void:
	direction *= -1

func _update_animation() -> void:
	match state:
		State.PATROL:
			_play_animation("Walk")
		State.CHASE:
			_play_animation("WalkFaster")
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
		_change_state(State.PATROL)


func die() -> void:
	_change_state(State.DEAD)
	velocity = Vector2.ZERO
