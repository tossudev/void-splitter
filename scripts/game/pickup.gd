extends Area2D

const SPEED: float = 0.5
const OFFSCREEN_VALUE: int = 256

# Node References
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var game_state: Node2D = get_node("/root/Game")

var time_elapsed: float = 0.0


func _physics_process(delta: float):
	position.y += SPEED * (delta * 60)
	
	# Kill entity if it goes off-screen
	if position.y >= OFFSCREEN_VALUE:
		queue_free()
	
	time_elapsed += delta
	var scale_value: float = (cos(time_elapsed * 6.0) * 0.1) + 0.8
	
	sprite.scale = Vector2(scale_value, scale_value)


func _on_body_entered(body):
	if body.name == "Player":
		Audio.play_effect("res://assets/sound/effects/pickup.wav")
		
		game_state.get_pickup()
		queue_free()
