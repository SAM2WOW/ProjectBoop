extends TextureButton

var tween
func _ready():
	if disabled:
		return
	
	connect("button_down", on_button_down)
	connect("button_up", on_button_up)
	connect("mouse_entered", on_mouse_entered)
	connect("mouse_exited", on_mouse_exited)

	set_pivot_offset(size / 2)


func on_button_down():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	#tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)


func on_button_up():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	#tween.parallel().tween_property(self, "modulate", Color("a68a56"), 0.5)


func on_mouse_entered():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)


func on_mouse_exited():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15)
