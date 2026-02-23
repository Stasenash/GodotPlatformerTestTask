extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var respawn_point: Marker2D = $RespawnPoint

func _on_death_zone_body_entered(body: Node2D) -> void:
		if body == player:
			_respawn_player()
		
func _respawn_player() -> void:
	player.global_position = respawn_point.global_position
	player.velocity = Vector2.ZERO
