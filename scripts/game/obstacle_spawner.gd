extends Node2D

const SPAWN_AREA_WIDTH: int = 120

@onready var obstacle_scene: PackedScene = preload("res://scenes/obstacle.tscn")
@onready var timer: Timer = get_node("SpawnIntervalTimer")
@onready var game_state: Node2D = get_node("/root/Game")


func _ready():
	await get_tree().create_timer(2.0).timeout
	
	timer.start(game_state.obstacle_spawn_rate)


func _spawn_obstacle():
	var new_obstacle: Area2D = obstacle_scene.instantiate()
	add_child(new_obstacle)
	
	var obstacle_pos := Vector2(
		randi_range(-SPAWN_AREA_WIDTH, SPAWN_AREA_WIDTH),
		position.y
	)
	new_obstacle.position = obstacle_pos
	
	timer.start(game_state.obstacle_spawn_rate)


func _on_spawn_interval_timer_timeout():
	_spawn_obstacle()
