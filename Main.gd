extends Node2D


var click_pos

var menu = false
var snapDistance = 50

var character_list = []
var current_character = 0

var texture_count = 0
var single_texture_name
var default_texture
var open_texture

var audio_list = []
var speech_list = []

var base_path = "user://levels/"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	DisplayServer.window_set_current_screen(0)
	DisplayServer.window_set_size(Vector2i(512, 256))
	DisplayServer.window_set_position(Vector2(0, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).y - 470))
	
	#get_tree().root.transparent = true
	#get_tree().root.transparent_bg = true
	
	#get_viewport().transparent = true
	#get_viewport().transparent_bg = true
	
	#SoundPlayer.play(["Kirin1", "Kirin3", "Kirin4"][randi() % 3])
	#SoundPlayer.speak()
	
	if OS.has_feature("release"):
		base_path = OS.get_executable_path().get_base_dir() + "/data/"
		
	dir_contents(base_path)
	
	#for i in character_list:
	#	dir_contents(base_path + "%s" % i)
	
	# load the first character
	load_character(character_list[0])
	



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
				if file_name.get_extension() in ["wav", "mp3", "ogg"]:
					audio_list.append(file_name)
				
				elif file_name.get_extension() in ["png", "PNG"]:
					texture_count += 1
					single_texture_name = file_name
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func _process(delta):
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


func _on_exit_pressed():
	get_tree().quit()


func _on_switch_pressed():
	DisplayServer.window_set_current_screen(wrapi(DisplayServer.window_get_current_screen() + 1, 0, DisplayServer.get_screen_count()))


func _on_sfx_pressed():
	AudioServer.set_bus_mute(1, not AudioServer.is_bus_mute(1))
	
	$CanvasLayer/Control/CenterContainer/HBoxContainer/VBoxContainer2/SFX/Label.set_text("Sound - %s" % ["ON", "OFF"][int(AudioServer.is_bus_mute(1))])


func _on_timer_timeout():
	$Face.speaking()
	
	$Timer.start(randf_range(20.0, 50.0))


func _on_change_pressed():
	current_character = wrapi(current_character + 1, 0, len(character_list))
	
	load_character(character_list[current_character])


func load_character(character):
	# change hint name
	$CanvasLayer/Control/CenterContainer/HBoxContainer/VBoxContainer2/Tuber.set_text(character)
	
	# load all the sprites from the directory
	dir_contents(base_path + "%s" % character)
	
	# load default sprite
	var image
	
	# if player doesn't have anything
	if texture_count < 1:
		image = Image.load_from_file("res://arts/ui/huh.png")
	elif texture_count == 1:
		image = Image.load_from_file(base_path + "%s/%s" % [character, single_texture_name])
	else:
		image = Image.load_from_file(base_path + "%s/%s" % [character, "close.png"])
	
	default_texture = ImageTexture.create_from_image(image)
	var new_width = float(default_texture.get_width()) * (512.0 / float(default_texture.get_height()))
	default_texture.set_size_override(Vector2i(round(new_width), 512))
	
	$Face.set_texture(default_texture)
	$Face/FaceShadow.set_texture(default_texture)
	
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
	for i in audio_list:
		SoundPlayer.add_speech(base_path + "%s/%s" % [character, i])
	
	#print(SoundPlayer.speech)
	
	# load the speech files
	if FileAccess.file_exists(base_path + "%s/%s" % [character, "speech.txt"]):
		var file = FileAccess.open(base_path + "%s/%s" % [character, "speech.txt"], FileAccess.READ)
		var content = file.get_as_text()
		speech_list = content.split("\r\n", false)
	
		print(speech_list)


func change_speech_face(open):
	return
	
	$Face.set_texture(open_texture if open else default_texture)
	$Face/FaceShadow.set_texture(open_texture if open else default_texture)
