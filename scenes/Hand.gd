extends Sprite2D

var tween

var normal_texture = get_texture()
var pet_texture = preload("res://arts/sprites/handpet.png")
var drag_texture = preload("res://arts/sprites/handdrag.png")

enum STATE {NORMAL, DRAG, PET}
var current_state = STATE.NORMAL

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#set_scale(Vector2(0.8, 1.5))
			if tween:
				tween.kill()
				
			tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(0.9, 0.6), 0.1)
			tween.parallel().tween_property($Handshadow, "position", Vector2(90, 114.495), 0.1)
		
		if not event.is_pressed():
			#set_scale(Vector2(0.8, 1.5))
			if tween:
				tween.kill()
				
			tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(1, 1), 0.4)
			tween.parallel().tween_property($Handshadow, "position", Vector2(90, 140), 0.1)
	
func _process(delta):
	set_global_position(get_global_mouse_position())


func set_state(new_state):
	if current_state != new_state:
		current_state = new_state
		
		#print("NEW HAND STATE %d" % new_state)
		
		match current_state:
			STATE.NORMAL:
				get_material().set_shader_parameter("main_texture", normal_texture)
				$Handshadow.get_material().set_shader_parameter("main_texture", normal_texture)
				#set_texture(normal_texture)
				#$Handshadow.set_texture(normal_texture)
			STATE.DRAG:
				get_material().set_shader_parameter("main_texture", drag_texture)
				$Handshadow.get_material().set_shader_parameter("main_texture", drag_texture)
			STATE.PET:
				get_material().set_shader_parameter("main_texture", pet_texture)
				$Handshadow.get_material().set_shader_parameter("main_texture", pet_texture)
