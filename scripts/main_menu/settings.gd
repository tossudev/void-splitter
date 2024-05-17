extends Control

@export var save_settings: bool = true

const SETTINGS_FILEPATH: String = "user://settings.cfg"
const DEFAULT_VOLUME: float = 0.75

@onready var volume_node_master = $VolumeMaster
@onready var volume_node_music = $VolumeMusic
@onready var volume_node_sfx = $VolumeSfx
@onready var button_back: Control = $"../ButtonBack"

#region Saved variables
var is_fullscreen: bool = false
var audio_master: float = 0.0
var audio_music: float = 0.0
var audio_sfx: float = 0.0
#endregion


func _ready():
	_init_settings()


func update_ui() -> void:
	# Set UI audio values correctly.
	volume_node_master.get_node("Master").set_value(audio_master)
	volume_node_master.get_node("SliderBackground").set_value(audio_master)
	volume_node_music.get_node("Music").set_value(audio_music)
	volume_node_music.get_node("SliderBackground").set_value(audio_music)
	volume_node_sfx.get_node("Sfx").set_value(audio_sfx)
	volume_node_sfx.get_node("SliderBackground").set_value(audio_sfx)
	
	# Update window mode
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	$ButtonFullscreen.set_pressed(is_fullscreen)
	
	# Toggle visibility on checkboxes that are checked.
	for toggle_button_node in get_tree().get_nodes_in_group("togglebuttons"):
		var checkbox: TextureRect = toggle_button_node.get_node(
			"Contents/CheckBox/Checked")
		
		checkbox.set_visible(toggle_button_node.is_pressed())


func convert_audio_value(value: float):
	# Use a logarithmic equation to make volume slider stable.
	value = log(value) * 17.3123
	return value


func _init_settings() -> void:
	var settings_file: ConfigFile = ConfigFile.new()
	var can_load_settings = settings_file.load(SETTINGS_FILEPATH)
	
	# If there is no settings file or saving is disabled, use default settings.
	if can_load_settings != OK || !save_settings:
		_use_default_settings()
		return
	
	# Load settings from disk.
	_load_settings(settings_file)


func _use_default_settings() -> void:
	# Set default volume displays
	audio_master = DEFAULT_VOLUME
	audio_music = DEFAULT_VOLUME
	audio_sfx = DEFAULT_VOLUME
	
	# Set default volumes
	AudioServer.set_bus_volume_db(0, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(1, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(2, convert_audio_value(DEFAULT_VOLUME))
	
	update_ui()
	_save_settings()


func _save_settings() -> void:
	if !save_settings:
		return
	
	var settings_file = ConfigFile.new()
	
	# Save audio values
	audio_master = volume_node_master.get_node("Master").get_value()
	audio_music = volume_node_music.get_node("Music").get_value()
	audio_sfx = volume_node_sfx.get_node("Sfx").get_value()
	
	settings_file.set_value("audio", "master", audio_master)
	settings_file.set_value("audio", "music", audio_music)
	settings_file.set_value("audio", "sfx", audio_sfx)
	
	settings_file.set_value("screen", "is_fullscreen", is_fullscreen)
	
	settings_file.save(SETTINGS_FILEPATH)


func _load_settings(settings_file: ConfigFile) -> void:
	if !save_settings:
		return
	
	# Load audio values
	audio_master = settings_file.get_value("audio", "master")
	audio_music = settings_file.get_value("audio", "music")
	audio_sfx = settings_file.get_value("audio", "sfx")
	
	volume_node_master.get_node("Master").set_value(audio_master)
	volume_node_music.get_node("Music").set_value(audio_music)
	volume_node_sfx.get_node("Sfx").set_value(audio_sfx)
	
	is_fullscreen = settings_file.get_value("screen", "is_fullscreen")
	
	update_ui()


func _on_button_fullscreen_pressed():
	is_fullscreen = !is_fullscreen
	
	update_ui()


func _on_master_value_changed(value):
	volume_node_master.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(0, convert_audio_value(value))


func _on_music_value_changed(value):
	volume_node_music.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(1, convert_audio_value(value))


func _on_sfx_value_changed(value):
	volume_node_sfx.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(2, convert_audio_value(value))


func _on_button_back_pressed():
	_save_settings()
