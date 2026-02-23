extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var respawn_point: Marker2D = $RespawnPoint
@onready var hud: CanvasLayer = $HUD
@onready var game_over: CanvasLayer = $GameOverScreen
@onready var finish: Area2D = $FinishZone

var kill_count: int = 0

func _ready():
	hud.set_max_health(player.max_health)
	
	game_over.restart_requested.connect(_restart_level)
	game_over.menu_requested.connect(_go_to_menu)
	
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	
	finish.level_completed.connect(_on_level_completed)
	game_over.restart_requested.connect(_restart_level)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.died.connect(_on_enemy_died)

func _on_death_zone_body_entered(body: Node2D) -> void:
		if body == player:
			player.respawn(respawn_point.global_position)

func _on_player_health_changed(current: int, max: int) -> void:
	hud.update_health(current)	

func _on_level_completed() -> void:
	game_over.show_result(true, kill_count)

func _on_enemy_died() -> void:
	kill_count += 1
	hud.update_kills(kill_count)

func _on_player_died() -> void:
	game_over.show_result(false, kill_count)

func _restart_level() -> void:
	get_tree().reload_current_scene()
	
func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
