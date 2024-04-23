extends Node

var savePath = "user://settings.cfg"
var settings = {
	"Popups" : 1,
	"SoundVolume" : 1.0,
	"WindowSize" : 1.0,
	"BoopHotkey" : "BackSlash",
}

func _ready():
	if OS.has_feature("release"):
		savePath = OS.get_executable_path().get_base_dir() + "/settings.cfg"
	
	if not FileAccess.file_exists(savePath):
		save_settings()
	else:
		load_settings()
		
		# set all the values
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(settings.SoundVolume))
		
		# change hot key
		var keycode = OS.find_keycode_from_string(settings.BoopHotkey)
		var keyEvent = InputEventKey.new()
		keyEvent.set_keycode(keycode)
		InputMap.action_erase_events("Boop")
		InputMap.action_add_event("Boop", keyEvent)
		GlobalInput._initialize_global_input_c_sharp()
		
		


func delete_saves():
	# HTML5 Cookie bug fixes
	if not OS.is_userfs_persistent():
		return
	
	if FileAccess.file_exists(savePath):
		var dir = DirAccess.open("user://")
		dir.remove("settings.cfg")


func save_settings():
	# HTML5 Cookie bug fixes
	if not OS.is_userfs_persistent():
		return 
	
	# Create new ConfigFile object.
	var config = ConfigFile.new()

	# Store some values.
	for i in settings.keys():
		config.set_value("Default", i, settings[i])

	# Save it to a file (overwrite if already exists).
	config.save(savePath)


func load_settings():
	# HTML5 Cookie bug fixes
	if not OS.is_userfs_persistent():
		return 
	
	# Load data from a file.
	var config = ConfigFile.new()
	var err = config.load(savePath)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	# Iterate over all sections.
	for player in config.get_sections():
		for key in config.get_section_keys(player):
			settings[key] = config.get_value(player, key)
