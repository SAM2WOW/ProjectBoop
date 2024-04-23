extends Node2D

var click_pos

var hovering = false

var menu = false
var snapDistance = 50

var character_list = []
var current_character = 0

var texture_count = 0
var single_texture_name

var speech_count = 0
var single_speech_name

var default_texture
var open_texture

var audio_list = []
var speech_list = {}

var base_path = "user://levels/"

var setting_menu_scene = preload("res://scenes/SettingMenu.tscn")
var setting_opened = false
var setting_menu

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	DisplayServer.window_set_current_screen(0)
	
	var newScale = SaveSystem.settings.WindowSize
	DisplayServer.window_set_size(Vector2i(512 * newScale, 256 * newScale), 0)
	
	# move the window to the corner
	DisplayServer.window_set_position(Vector2(0, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).y - 470 * newScale))
	
	#get_tree().root.transparent = true
	#get_tree().root.transparent_bg = true
	
	#get_viewport().transparent = true
	#get_viewport().transparent_bg = true
	
	#SoundPlayer.play(["Kirin1", "Kirin3", "Kirin4"][randi() % 3])
	#SoundPlayer.speak()
	
	if OS.has_feature("release"):
		base_path = OS.get_executable_path().get_base_dir() + "/data/"
	
	# find all the characters
	dir_contents(base_path)
	
	#for i in character_list:
	#	dir_contents(base_path + "%s" % i)
	
	# load the first character
	if SaveSystem.settings.DefaultComp != "":
		load_character(SaveSystem.settings.DefaultComp)
	else:
		load_character(character_list[0])
	
	# update volume UI text
	$CanvasLayer/Control/CenterContainer/HBoxContainer/VBoxContainer2/SFX/HBoxContainer/Label.set_text(str(SaveSystem.settings.SoundVolume))
	

func dir_contents(path):
	audio_list.clear()
	texture_count = 0
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				
				character_list.append(file_name)
			else:
				print("Found file: " + file_name)
				
				# check if file is audio
				if file_name.get_extension().to_lower() in ["wav", "mp3", "ogg"]:
					audio_list.append(file_name)
				
				elif file_name.get_extension().to_lower() in ["png"]:
					texture_count += 1
					single_texture_name = file_name
				
				elif file_name.get_extension().to_lower() in ["txt"]:
					speech_count += 1
					single_speech_name = file_name
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
		#var confirmation_dialogue := NativeAcceptDialog.new()
		#confirmation_dialogue.title = "Ooops!?"
		#confirmation_dialogue.dialog_text = "Seem like you don't have any companions right now.. Check the README for tutorial on adding companions."
		#add_child(confirmation_dialogue)
		
		$NativeAcceptDialog.show()
		
		#get_tree().quit()


func _process(delta):
	#set_position(lerp(get_position(), Vector2(0, 25 * int(hovering)), delta * 20))
	
	if Input.is_action_just_pressed("menu"):
		click_pos = get_local_mouse_position()
	
	if Input.is_action_just_released("menu"):
		var distance = click_pos.distance_to(get_local_mouse_position())
		
		if distance <= 2:
			if not menu:
				menu = true
				$CanvasLayer.show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				$Hand.hide()
				
				SoundPlayer.play("UI")
			else:
				menu = false
				$CanvasLayer.hide()
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
				$Hand.show()
		
	if Input.is_action_pressed("menu"):
		var new_pos = Vector2(get_window().get_position()) + get_global_mouse_position() - click_pos
		#DisplayServer.window_set_position(Vector2(0, new_pos.y))
		#DisplayServer.window_set_position(new_pos)
		
		# Snap to the left edge if close
		if new_pos.x < snapDistance:
			new_pos.x = 0
		
		get_window().set_position(lerp(Vector2(get_window().get_position()), Vector2(new_pos), delta * 20))
		
		$Face.set_self_modulate(lerp($Face.get_self_modulate(), Color.TRANSPARENT, delta * 20))
		$Face/FaceShadow.get_material().set_shader_parameter("mod_color", lerp($Face/FaceShadow.get_material().get_shader_parameter("mod_color"), Vector4(0.5, 0.5, 0.5, 0.5), delta * 20))
	else:
		$Face.set_self_modulate(lerp($Face.get_self_modulate(), Color.WHITE, delta * 20))
		$Face/FaceShadow.get_material().set_shader_parameter("mod_color", lerp($Face/FaceShadow.get_material().get_shader_parameter("mod_color"), Vector4(0, 0, 0, 0.7), delta * 20))

func _on_exit_pressed():
	get_tree().quit()


func _on_switch_pressed():
	if setting_opened:
		setting_menu.popup_centered()
		return
	
	#DisplayServer.window_set_current_screen(wrapi(DisplayServer.window_get_current_screen() + 1, 0, DisplayServer.get_screen_count()))
	setting_menu = setting_menu_scene.instantiate()
	setting_menu.set_flag(Window.FLAG_BORDERLESS, false)
	setting_menu.set_flag(Window.FLAG_TRANSPARENT, false)
	setting_menu.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	
	setting_menu.main = self
	
	add_child(setting_menu)
	#s.position = Vector2(0, 0)
	setting_menu.visible = true
	setting_menu.popup_centered()
	
	setting_opened = true


func _on_sfx_pressed():
	#AudioServer.set_bus_mute(1, not AudioServer.is_bus_mute(1))
	
	var newVolume = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")))
	
	if newVolume > 0.0:
		newVolume = 0.0
	elif newVolume == 0.0:
		newVolume = 1.0
	
	SaveSystem.settings.SoundVolume = newVolume
	SaveSystem.save_settings()
	
	$CanvasLayer/Control/CenterContainer/HBoxContainer/VBoxContainer2/SFX/HBoxContainer/Label.set_text("x" + str(SaveSystem.settings.SoundVolume))
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(newVolume))
	


func _on_timer_timeout():
	$Face.speaking()
	
	$Timer.start(randf_range(20.0, 50.0))


func _on_change_pressed():
	current_character = wrapi(current_character + 1, 0, len(character_list))
	
	load_character(character_list[current_character])


func load_character(character):
	# change hint name
	$CanvasLayer/Control/CenterContainer/HBoxContainer/VBoxContainer2/Tuber.set_text(character)
	
	# save to settings
	SaveSystem.settings.DefaultComp = character
	SaveSystem.save_settings()
	
	# load all the sprites from the directory
	dir_contents(base_path + "%s" % character)
	
	# load default sprite
	var image
	
	# if player doesn't have anything
	if texture_count < 1:
		image = Image.new()
		image.load("res://arts/ui/huh.png")
	elif texture_count == 1:
		image = Image.load_from_file(base_path + "%s/%s" % [character, single_texture_name])
	else:
		image = Image.load_from_file(base_path + "%s/%s" % [character, "close.png"])
	
	default_texture = ImageTexture.create_from_image(image)
	var new_width = float(default_texture.get_width()) * (512.0 / float(default_texture.get_height()))
	default_texture.set_size_override(Vector2i(round(new_width), 512))
	
	$Face.set_texture(default_texture)
	$Face/FaceShadow.set_texture(default_texture)
	
	# reset tapping
	$Face.tapping = 0
	$Face.happiness = 0.0
	$Face.happy = false
	
	$Face/Area2D/HappyParticle.set_emitting(false)
	$Face/Area2D/HappyParticle2.set_emitting(false)
	$Face/Area2D/HappyParticle3.set_emitting(false)
	
	# load mouth open sprite
	var image2
	if FileAccess.file_exists(base_path + "%s/%s" % [character, "open.png"]):
		image2 = Image.load_from_file(base_path + "%s/%s" % [character, "open.png"])
	else:
		image2 = image
	
	open_texture = ImageTexture.create_from_image(image2)
	open_texture.set_size_override(Vector2i(round(float(default_texture.get_width()) * (512.0 / float(default_texture.get_height()))), 512))
	
	# load all the sound files
	SoundPlayer.clear_speech()
	print(audio_list)
	for i in audio_list:
		SoundPlayer.add_speech(base_path + "%s/%s" % [character, i])
		
	# customize boop sound
	if "boop.mp3" in audio_list:
		pass
	
	#print(SoundPlayer.speech)
	
	# load the speech files
	# if there's only one file, load that one
	if not speech_list.has(character):
		var new_path
		if speech_count != 1:
			new_path = base_path + "%s/%s" % [character, "speech.txt"]
		else:
			new_path = base_path + "%s/%s" % [character, single_speech_name]
		
		if FileAccess.file_exists(new_path):
			var file = FileAccess.open(new_path, FileAccess.READ)
			var content = file.get_as_text()
			speech_list[character] = content.split("\r\n", false)
	
	# find all the characters
	dir_contents(base_path)
	
	# reset timer
	$Timer.start(10)


func change_speech_face(open):
	$Face.set_texture(open_texture if open else default_texture)
	$Face/FaceShadow.set_texture(open_texture if open else default_texture)


func _on_area_2d_mouse_entered():
	hovering = true


func _on_area_2d_mouse_exited():
	hovering = false


func _on_native_accept_dialog_confirmed():
	get_tree().quit()
