extends CanvasLayer

const OVERLAY_OFFSET := Vector2i(0, 0)
const OPTION_COLOR_GRAY := Color(0.6, 0.6, 0.6, 1.0)

@onready var label_time: Label = get_node("TextTime")
@onready var label_points: Label = get_node("TextPoints")
@onready var game_state: Node2D = get_node("/root/Game")
@onready var player: CharacterBody2D = get_node("/root/Game/Player")

@onready var option1: NinePatchRect = get_node("Shop/Option1")
@onready var option2: NinePatchRect = get_node("Shop/Option2")
@onready var purchase_info: Label = get_node("Shop/TextPurchaseInfo")

var time_elapsed: float = 0.0


func _ready():
	set_offset(OVERLAY_OFFSET)
	_fade_out_controls()


func _process(delta: float):
	time_elapsed += delta
	var scale_value: float = (cos(time_elapsed * 6.0) * 0.2) + 1.0
	
	if Input.is_action_just_pressed("purchase"):
		game_state.make_purchase()
	
	_update_ui(scale_value)


func get_formatted_time(time: float) -> String:
	var minutes = time / 60
	var seconds = fmod(time, 60)
	
	var time_formatted: String = "%02d:%02d" % [minutes, seconds]
	return time_formatted


func game_over():
	var time_formatted: String = get_formatted_time(game_state.time_survived)
	var final_text: String = "Final Time:\n" + time_formatted
	
	$EndScreen/TextTime.set_text(final_text)
	$EndScreen.show()


func _update_ui(scale_value: float):
	if game_state.game_over:
		return
	
	var time_formatted: String = get_formatted_time(game_state.time_survived)
	label_time.set_text(time_formatted)
	label_points.set_text(str(game_state.points))
	
	var points: int = game_state.points
	
	var can_get_option1: bool = !game_state.player_damage >= game_state.PLAYER_MAX_DAMAGE
	var can_get_option2: bool = !player.health >= player.MAX_HEALTH
	
	option1.set_visible(can_get_option1)
	option2.set_visible(can_get_option2)
	purchase_info.set_scale(Vector2(scale_value, scale_value))
	
	# Second purchase
	if points >= game_state.PURCHASE_COSTS[1]:
		if can_get_option2:
			option1.set_scale(Vector2.ONE)
			option1.set_modulate(OPTION_COLOR_GRAY)
			
			option2.set_scale(Vector2(scale_value, scale_value))
			option2.set_modulate(Color.WHITE)
			purchase_info.show()
			return
	
	# First purchase
	if points >= game_state.PURCHASE_COSTS[0] and points < game_state.PURCHASE_COSTS[1]:
		if can_get_option1:
			option1.set_scale(Vector2(scale_value, scale_value))
			option1.set_modulate(Color.WHITE)
			
			option2.set_scale(Vector2.ONE)
			option2.set_modulate(OPTION_COLOR_GRAY)
			purchase_info.show()
			purchase_info.set_scale(Vector2(scale_value, scale_value))
			return
	
	# Set default values for both options if neither can be purchased
	option1.set_scale(Vector2.ONE)
	option2.set_scale(Vector2.ONE)
	
	option1.set_modulate(OPTION_COLOR_GRAY)
	option2.set_modulate(OPTION_COLOR_GRAY)
	purchase_info.hide()


func _fade_out_controls():
	await get_tree().create_timer(4.0).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_property(
		$TextControls, "modulate",
		Color.TRANSPARENT,
		2.0
	)
