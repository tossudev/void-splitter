extends Node

# Node References
@onready var player_effects: AudioStreamPlayer = $PlayerEffects


# Load sound effect from path and create new sound object to play it
func play_effect(file_path: String) -> void:
	var sound: AudioStream = load(file_path)
	
	var sound_player_instance: AudioStreamPlayer = player_effects.duplicate()
	add_child(sound_player_instance)
	
	sound_player_instance.finished.connect(
		_on_player_duplicate_finished.bind(sound_player_instance)
		)
	
	sound_player_instance.set_stream(sound)
	sound_player_instance.play()


# Finished sound player is killed
func _on_player_duplicate_finished(player: AudioStreamPlayer) -> void:
	player.queue_free()
