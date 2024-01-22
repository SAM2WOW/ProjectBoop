extends Node2D


var click_pos

var menu = false

var character_list = []
var current_character = 0

var default_texture
var open_texture

var audio_list = []

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
	SoundPlayer.speak()
	
	var app_path = OS.get_executable_path()
	print(app_path)
	dir_contents("user://levels")
	
	for i in character_list:
		dir_contents("user://levels/%s" % i)


func dir_contents(path):
	audio_list.clear()
	
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
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func _process(delta):
	if Input.is_action_just_pressed("menu"):
		click_pos = get_local_mouse_position()
		
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
		var new_pos = Vector2(DisplayServer.window_get_position()) + get_global_mouse_position() - click_pos
		#DisplayServer.window_set_position(Vector2(0, new_pos.y))
		DisplayServer.window_set_position(new_pos)


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
	
	# load all the sprites from the directory
	dir_contents("user://levels/%s" % character_list[current_character])
	
	# load default sprite
	var image = Image.load_from_file("user://levels/%s/%s" % [character_list[current_character], "close.png"])
	#print("user://levels/%s/%s" % [character_list[current_character], "close.png"])
	default_texture = ImageTexture.create_from_image(image)
	var new_width = float(default_texture.get_width()) * (512.0 / float(default_texture.get_height()))
	default_texture.set_size_override(Vector2i(round(new_width), 512))
	
	$Face.set_texture(default_texture)
	$Face/FaceShadow.set_texture(default_texture)
	
	# load mouth open sprite
	var image2 = Image.load_from_file("user://levels/%s/%s" % [character_list[current_character], "open.png"])
	
	# check if open image is included, else restore to default
	if not image2:
		image2 = image
	
	open_texture = ImageTexture.create_from_image(image2)
	open_texture.set_size_override(Vector2i(round(float(default_texture.get_width()) * (512.0 / float(default_texture.get_height()))), 512))
	
	# load all the sound files
	for i in audio_list:
		print(i)

func change_speech_face(open):
	print(open)
	$Face.set_texture(open_texture if open else default_texture)
	$Face/FaceShadow.set_texture(open_texture if open else default_texture)
