extends Node2D

const PROGRESSION_INTERVAL: int = 10 # Time between stages of difficulty
const FINAL_STAGE_SPAWN_RATE: float = 0.2
const FINAL_STAGE_OBSTACLE_HEALTH: float = 11
const PLAYER_MAX_DAMAGE: int = 5
const PURCHASE_COSTS: Array = [2, 4]

var time_survived: float = 0.0
var points: int = 0
var player_damage: int = 1
var obstacle_spawn_rate: float = 1.0
var obstacle_health: int = 3
var game_over: bool = false

# Node References
@onready var player: CharacterBody2D = get_node("Player")


func _ready():
	# Wait for player to read instructions and figure out movement
	await get_tree().create_timer(2.0).timeout
	
	_start_game()


func end_game():
	game_over = true
	$Overlay.game_over()


func make_purchase():
	if points >= PURCHASE_COSTS[0] and points < PURCHASE_COSTS[1]:
		if player_damage >= PLAYER_MAX_DAMAGE:
			return
		
		points -= PURCHASE_COSTS[0]
		player_damage += 1
	
	elif points >= PURCHASE_COSTS[1]:
		if player.health >= player.MAX_HEALTH:
			return
		
		points -= PURCHASE_COSTS[1]
		player.health += 1
		player.update_clones()
	
	Audio.play_effect("res://assets/sound/effects/purchase.wav")


func _start_game():
	$ProgressionTimer.start(PROGRESSION_INTERVAL)


func _process(delta: float):
	if game_over:
		if Input.is_action_just_pressed("shoot"):
			SceneChanger.change_scene("res://scenes/main_menu.tscn")
		
		return
	
	time_survived += delta


func get_pickup():
	points += 1


# Game progression
func _on_progression_timer_timeout():
	# Obstacles spawn faster after each 'stage'
	if obstacle_spawn_rate > FINAL_STAGE_SPAWN_RATE:
		obstacle_spawn_rate -= 0.1
	
	# Obstacles get more health after each 'stage'
	if obstacle_health < FINAL_STAGE_OBSTACLE_HEALTH:
		obstacle_health += 1
	
	$ProgressionTimer.start(PROGRESSION_INTERVAL)
	
