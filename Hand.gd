extends Sprite2D

var tween

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#set_scale(Vector2(0.8, 1.5))
			if tween:
				tween.kill()
				
			tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(0.9, 0.6), 0.1)
		
		if not event.is_pressed():
			#set_scale(Vector2(0.8, 1.5))
			if tween:
				tween.kill()
				
			tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(1, 1), 0.4)
	
func _process(delta):
	set_global_position(get_global_mouse_position())
