extends Node2D


var click_pos

var menu = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	DisplayServer.window_set_current_screen(0)
	DisplayServer.window_set_size(Vector2i(512, 256))
	DisplayServer.window_set_position(Vector2(0, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()).y - 470))
	
	#get_tree().root.transparent = true
	#get_tree().root.transparent_bg = true
	
	#get_viewport().transparent = true
	#get_viewport().transparent_bg = true
	
	SoundPlayer.play(["Kirin1", "Kirin3", "Kirin4"][randi() % 3])


func _process(delta):
	if Input.is_action_just_pressed("menu"):
		click_pos = get_local_mouse_position()
		
		if not menu:
			menu = true
			$CanvasLayer.show()
		else:
			menu = false
			$CanvasLayer.hide()
		
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
	
	$CanvasLayer/Control/CenterContainer/VBoxContainer/SFX/Label.set_text("Sound - %s" % ["ON", "OFF"][int(AudioServer.is_bus_mute(1))])


func _on_timer_timeout():
	$Face.speaking()
	
	$Timer.start(randf_range(20.0, 50.0))
