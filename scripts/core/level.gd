extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var respawn_point: Marker2D = $RespawnPoint
@onready var hud: CanvasLayer = $HUD

var kill_count: int = 0

func _ready():
	hud.set_max_health(player.max_health)
	player.health_changed.connect(_on_player_health_changed)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.died.connect(_on_enemy_died)

func _on_death_zone_body_entered(body: Node2D) -> void:
		if body == player:
			player.respawn(respawn_point.global_position)

func _on_player_health_changed(current: int, max: int) -> void:
	hud.update_health(current)	

func _on_enemy_died() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
