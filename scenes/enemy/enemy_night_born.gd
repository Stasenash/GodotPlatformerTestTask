extends CharacterBody2D

var follow = false
var speed = 100

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../Player"
	var direction = (player.position - self.position).normalized()
	if follow:
		velocity.x = direction.x * speed
		animation.play("Walk")
	else:
		velocity.x = 0
		animation.play("Idle")
	move_and_slide()
	
func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		follow = true


func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		follow = false
