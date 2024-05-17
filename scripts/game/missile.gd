extends Area2D

const SPEED: float = -8.0
const FLASH_SPEED: int = 2
const FLASH_COLOR := Color(10.0, 10.0, 10.0, 1.0)

var flash_counter: int = FLASH_SPEED
var flash_on: bool = false


func _physics_process(_delta):
	position.y += SPEED
	
	_do_flash()


func _do_flash():
	flash_counter -= 1
	
	if flash_counter <= 0:
		flash_counter = FLASH_SPEED
		flash_on = !flash_on
		
		if flash_on:
			set_modulate(FLASH_COLOR)
		else:
			set_modulate(Color.WHITE)


func _on_area_entered(area):
	area.take_damage()
	
	queue_free()


func _on_kill_timer_timeout():
	queue_free()
