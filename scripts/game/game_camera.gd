extends Camera2D

const SHAKE_TIME: float = 0.2
const MAX_SHAKE_AMOUNT: float = 0.5

var shaking: bool = false


func _process(_delta):
	# Give camera random offset for shake effect
	if shaking:
		var new_offset := Vector2(
			randf_range(-MAX_SHAKE_AMOUNT, MAX_SHAKE_AMOUNT),
			randf_range(-MAX_SHAKE_AMOUNT, MAX_SHAKE_AMOUNT)
		)
		
		offset = new_offset


func shake_camera():
	shaking = true
	$ShakeTimer.start(SHAKE_TIME)


func _on_shake_timer_timeout():
	shaking = false
	offset = Vector2.ZERO
