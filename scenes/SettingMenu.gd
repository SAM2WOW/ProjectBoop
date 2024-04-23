extends Window

@export var PopupsBtn: NodePath
@export var SoundVolumeNode: NodePath
@export var SoundVolumeLabel: NodePath
@export var WindowsizeNode: NodePath
@export var WindowsizeLabel: NodePath
@export var BoopKey: NodePath

var input_setting = false
var main

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(PopupsBtn).set_pressed(bool(SaveSystem.settings.Popups))
	get_node(SoundVolumeNode).set_value(SaveSystem.settings.SoundVolume)
	get_node(SoundVolumeLabel).set_text(str(SaveSystem.settings.SoundVolume))
	
	get_node(WindowsizeNode).set_value(SaveSystem.settings.WindowSize)
	get_node(WindowsizeLabel).set_text(str(SaveSystem.settings.WindowSize) + "x")
	
	get_node(BoopKey).set_text(SaveSystem.settings.BoopHotkey)
	
	# change version code
	var version = ProjectSettings.get_setting("application/config/version")
	$Control/HBoxContainer/MarginContainer/TabContainer/General/General/VersionCode.set_text("Corner Companion Beta Build v" + str(version))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if not input_setting:
		return
	
	if event is InputEventKey:
		if event.pressed:
			#var inputEvents = InputMap.action_get_events("Boop")
			InputMap.action_erase_events("Boop")
			InputMap.action_add_event("Boop", event)
			GlobalInput._initialize_global_input_c_sharp()
			
			var key_name = OS.get_keycode_string(event.get_key_label())
			print(key_name)
			
			get_node(BoopKey).set_text(key_name)
			
			SaveSystem.settings.BoopHotkey = key_name
			SaveSystem.save_settings()
			
			input_setting = false


func _on_close_requested():
	SaveSystem.save_settings()
	
	main.setting_opened = false
	queue_free()


func _on_sound_volume_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value))
	SaveSystem.settings.SoundVolume = value
	get_node(SoundVolumeLabel).set_text(str(SaveSystem.settings.SoundVolume))
	
	SaveSystem.save_settings()


func _on_window_size_slider_value_changed(value):
	SaveSystem.settings.WindowSize = value
	DisplayServer.window_set_size(Vector2i(512 * value, 256 * value), 0)
	DisplayServer.window_set_position(Vector2(0, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).y - 470 * value))
	
	get_node(WindowsizeLabel).set_text(str(SaveSystem.settings.WindowSize) + "x")
	
	SaveSystem.save_settings()


func _on_popup_check_button_toggled(toggled_on):
	SaveSystem.settings.Popups = int(toggled_on)
	SaveSystem.save_settings()


func _on_companion_folder_pressed():
	if OS.has_feature("release"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(OS.get_executable_path().get_base_dir()) + "/data")
	else:
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"))


func _on_tutorial_pressed():
	var filepath = ProjectSettings.globalize_path("user://") + "/README.txt"
	if OS.has_feature("release"):
		filepath = OS.get_executable_path().get_base_dir() + "/README.txt"
	OS.shell_open(filepath)


func _on_boop_hotkey_button_pressed():
	input_setting = true
	
	get_node(BoopKey).set_text("- Press Any Key -")
