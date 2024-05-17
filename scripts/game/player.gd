extends CharacterBody2D

const SPEED: float = 50.0
const MAX_SPEED: float = 900.0
const MAX_HEALTH: int = 3
const MOVEMENT_SMOOTHING: float = 0.2
const SHOOT_INTERVAL: float = 0.3
const DAMAGE_ANIM_TIME: float = 0.06
const DAMAGE_COLOR := Color.RED

# Node References
@onready var missile_scene: PackedScene = preload("res://scenes/missile.tscn")
@onready var fire_animation: AnimatedSprite2D = get_node("FireAnimation")
@onready var missiles_parent: Node2D = get_node("/root/Game/Missiles")
@onready var shoot_timer: Timer = get_node("ShootIntervalTimer")
@onready var game_state: Node2D = get_node("/root/Game")
@onready var game_camera: Camera2D = get_node("/root/Game/Camera")

var motion := Vector2.ZERO
var shoot_cooldown: bool = false
var health: int = 1
var playing_damage_anim: bool = false


func _ready():
	update_clones()


func _physics_process(delta: float):
	if game_state.game_over:
		return
	
	_update_movement(delta)
	_update_shooting()


func take_damage():
	health -= 1
	
	update_clones()
	
	if health <= 0:
		game_state.end_game()
		set_modulate(Color.RED)
		
		Audio.play_effect("res://assets/sound/effects/explosion_long.wav")
		return
	
	game_camera.shake_camera()
	_do_damage_anim()


# Update clone ship visibility according to health
func update_clones():
	for child in $Clones.get_children():
		child.hide()
	
	for i in health:
		if i != 0:
			$Clones.get_child(i - 1).show()


func _update_movement(_delta: float):
	if Input.is_action_pressed("move_left"):
		motion.x += -SPEED
	if Input.is_action_pressed("move_right"):
		motion.x += SPEED
	if Input.is_action_pressed("move_up"):
		motion.y += -SPEED
	if Input.is_action_pressed("move_down"):
		motion.y += SPEED
	
	motion.x = lerpf(motion.x, 0.0, MOVEMENT_SMOOTHING)
	motion.y = lerpf(motion.y, 0.0, MOVEMENT_SMOOTHING)
	
	if motion == Vector2.ZERO:
		fire_animation.play("idle")
	else:
		fire_animation.play("move")
	
	motion.x = clampf(motion.x, -MAX_SPEED, MAX_SPEED)
	motion.y = clampf(motion.y, -MAX_SPEED, MAX_SPEED)
	
	velocity = motion
	move_and_slide() # Move and slide applies delta automatically


func _update_shooting():
	if shoot_cooldown:
		return
	
	if Input.is_action_pressed("shoot"):
		_shoot_missile()
		shoot_cooldown = true
		shoot_timer.start(SHOOT_INTERVAL)


func _do_damage_anim():
	if playing_damage_anim:
		return
	
	playing_damage_anim = true
	
	set_modulate(DAMAGE_COLOR)
	await get_tree().create_timer(DAMAGE_ANIM_TIME).timeout
	set_modulate(Color.WHITE)
	
	playing_damage_anim = false


func _shoot_missile():
	if shoot_cooldown:
		return
	
	Audio.play_effect("res://assets/sound/effects/shoot.wav")
	
	# Shoot missile from player ship and all currently usable clones
	for i in health:
		var new_missile: Area2D = missile_scene.instantiate()
		missiles_parent.add_child(new_missile)
		
		# Player ship
		if i == 0:
			new_missile.global_position = $ShootPosition.global_position
		
		# Clones
		else:
			var shoot_pos_node = $Clones.get_child(i - 1).get_node("ShootPosition")
			new_missile.global_position = shoot_pos_node.global_position


func _on_shoot_interval_timer_timeout():
	shoot_cooldown = false
