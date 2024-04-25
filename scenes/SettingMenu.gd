extends Window

@export var PopupsBtn: NodePath
@export var SoundVolumeNode: NodePath
@export var SoundVolumeLabel: NodePath
@export var WindowsizeNode: NodePath
@export var WindowsizeLabel: NodePath
@export var BoopKeyToggle: NodePath
@export var BoopKey: NodePath
@export var SquishKeyToggle: NodePath
@export var SquishKey: NodePath
@export var SwitchKeyToggle: NodePath
@export var SwitchKey: NodePath

var input_setting = null
var main

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(PopupsBtn).set_pressed(bool(SaveSystem.settings.Popups))
	get_node(SoundVolumeNode).set_value(SaveSystem.settings.SoundVolume)
	get_node(SoundVolumeLabel).set_text(str(SaveSystem.settings.SoundVolume))
	
	get_node(WindowsizeNode).set_value(SaveSystem.settings.WindowSize)
	get_node(WindowsizeLabel).set_text(str(SaveSystem.settings.WindowSize) + "x")
	
	get_node(BoopKeyToggle).set_pressed(bool(SaveSystem.settings.BoopKeyToggle))
	get_node(BoopKey).set_text(SaveSystem.settings.BoopHotkey)

	get_node(SquishKeyToggle).set_pressed(bool(SaveSystem.settings.SquishKeyToggle))
	get_node(SquishKey).set_text(SaveSystem.settings.SquishHotkey)

	get_node(SwitchKeyToggle).set_pressed(bool(SaveSystem.settings.SwitchKeyToggle))
	get_node(SwitchKey).set_text(SaveSystem.settings.SwitchHotkey)
	
	# change version code
	var version = ProjectSettings.get_setting("application/config/version")
	$Control/HBoxContainer/MarginContainer/TabContainer/General/General/VersionCode.set_text("Corner Companion Beta Build v" + str(version))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if input_setting == null:
		return
	
	if event is InputEventKey:
		if event.pressed:
			if input_setting == "BoopKeyToggle":
				InputMap.action_erase_events("Boop")
				InputMap.action_add_event("Boop", event)
				GlobalInput._initialize_global_input_c_sharp()
				
				var key_name = OS.get_keycode_string(event.get_key_label())
				get_node(BoopKey).set_text(key_name)
				SaveSystem.settings[input_setting] = key_name
				
			elif input_setting == "SquishKeyToggle":
				InputMap.action_erase_events("Squish")
				InputMap.action_add_event("Squish", event)
				GlobalInput._initialize_global_input_c_sharp()
				
				var key_name = OS.get_keycode_string(event.get_key_label())
				get_node(SquishKey).set_text(key_name)
				SaveSystem.settings[input_setting] = key_name
				
			elif input_setting == "SwitchKeyToggle":
				InputMap.action_erase_events("Switch")
				InputMap.action_add_event("Switch", event)
				GlobalInput._initialize_global_input_c_sharp()
				
				var key_name = OS.get_keycode_string(event.get_key_label())
				get_node(SwitchKey).set_text(key_name)
				SaveSystem.settings[input_setting] = key_name
			
			SaveSystem.save_settings()
			
			input_setting = null


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
	input_setting = "BoopHotkey"
	
	get_node(BoopKey).set_text("- Press Any Key -")


func _on_squish_hotkey_button_pressed():
	input_setting = "SquishHotkey"

	get_node(SquishKey).set_text("- Press Any Key -")


func _on_switch_hotkey_button_pressed():
	input_setting = "SwitchHotkey"

	get_node(SwitchKey).set_text("- Press Any Key -")


func _on_boop_key_toggle_toggled(toggled_on):
	SaveSystem.settings.BoopKeyToggle = int(toggled_on)
	SaveSystem.save_settings()


func _on_squish_key_toggle_toggled(toggled_on):
	SaveSystem.settings.SquishKeyToggle = int(toggled_on)
	SaveSystem.save_settings()


func _on_switch_key_toggle_toggled(toggled_on):
	SaveSystem.settings.SwitchKeyToggle = int(toggled_on)
	SaveSystem.save_settings()


func _on_spin_box_value_changed(value):
	SaveSystem.settings.BoopCount = int(value)
	SaveSystem.save_settings()


func _on_general_pressed():
	$Control/HBoxContainer/MarginContainer/TabContainer.set_current_tab(0)


func _on_interaction_pressed():
	$Control/HBoxContainer/MarginContainer/TabContainer.set_current_tab(1)


func _on_others_pressed():
	$Control/HBoxContainer/MarginContainer/TabContainer.set_current_tab(2)
