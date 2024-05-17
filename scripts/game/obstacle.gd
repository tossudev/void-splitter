extends Area2D

const MAX_SPIN: float = 0.1
const SPEED: float = 1.0
const DAMAGE_ANIM_TIME: float = 0.06
const DAMAGE_COLOR := Color(10.0, 10.0, 10.0, 1.0)
const PICKUP_DROP_CHANCE: float = 0.2
const OFFSCREEN_VALUE: int = 256

# Node References
@onready var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var flame_sprite: AnimatedSprite2D = get_node("FlameAnimation")
@onready var game_camera: Camera2D = get_node("/root/Game/Camera")
@onready var game_state: Node2D = get_node("/root/Game")
@onready var pickups_parent: Node2D = get_node("/root/Game/Pickups")

var spin_amount: float = 0.0
var health: int = 3
var playing_damage_anim: bool = false
var dead: bool = false


func _ready():
	health = game_state.obstacle_health
	spin_amount = randf_range(-MAX_SPIN, MAX_SPIN)


func _physics_process(delta: float):
	if dead or game_state.game_over:
		return
	
	# Kill entity if it goes off-screen
	if position.y >= OFFSCREEN_VALUE:
		queue_free()
	
	sprite.rotation += spin_amount * (delta * 60)
	position.y += SPEED * (delta * 60)


func take_damage():
	health -= game_state.player_damage
	
	if health <= 0:
		_die()
		Audio.play_effect("res://assets/sound/effects/explosion.wav")
	
	else:
		_do_damage_anim()
		Audio.play_effect("res://assets/sound/effects/hit.wav")


func _die():
	dead = true
	
	if randf() <= PICKUP_DROP_CHANCE:
		_spawn_pickup_object()
	
	flame_sprite.hide()
	sprite.play("break")
	game_camera.shake_camera()
	
	await sprite.animation_finished
	
	queue_free()


func _spawn_pickup_object():
	var new_pickup: Area2D = pickup_scene.instantiate()
	pickups_parent.call_deferred("add_child", new_pickup)
	
	new_pickup.global_position = global_position


func _do_damage_anim():
	if playing_damage_anim:
		return
	
	playing_damage_anim = true
	
	set_modulate(DAMAGE_COLOR)
	await get_tree().create_timer(DAMAGE_ANIM_TIME).timeout
	set_modulate(Color.WHITE)
	
	playing_damage_anim = false


func _on_player_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage()
