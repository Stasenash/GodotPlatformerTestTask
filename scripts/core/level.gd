extends Node2D

const MENU_SCENE_PATH: String = "res://scenes/main_menu/main_menu.tscn"

@onready var _player: CharacterBody2D = $Player
@onready var _respawn_point: Marker2D = $RespawnPoint
@onready var _hud: CanvasLayer = $HUD
@onready var _game_over: CanvasLayer = $GameOverScreen
@onready var _finish: Area2D = $FinishZone

var _kill_count: int = 0


func _ready() -> void:
	_initialize_ui()
	_connect_player_signals()
	_connect_game_over_signals()
	_connect_finish_signal()
	_connect_enemy_signals()


# ================= Initialization =================

func _initialize_ui() -> void:
	_hud.set_max_health(_player.max_health)


func _connect_player_signals() -> void:
	_player.health_changed.connect(_on_player_health_changed)
	_player.died.connect(_on_player_died)


func _connect_game_over_signals() -> void:
	_game_over.restart_requested.connect(_restart_level)
	_game_over.menu_requested.connect(_go_to_menu)


func _connect_finish_signal() -> void:
	_finish.level_completed.connect(_on_level_completed)


func _connect_enemy_signals() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.died.connect(_on_enemy_died)


# ================= Gameplay Events =================

func _on_death_zone_body_entered(body: Node2D) -> void:
	if body == _player:
		_player.respawn(_respawn_point.global_position)


func _on_player_health_changed(current: int, _max: int) -> void:
	_hud.update_health(current)


func _on_enemy_died() -> void:
	_kill_count += 1
	_hud.update_kills(_kill_count)


func _on_player_died() -> void:
	_game_over.show_result(false, _kill_count)


func _on_level_completed() -> void:
	_game_over.show_result(true, _kill_count)


# ================= Scene Control =================

func _restart_level() -> void:
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
