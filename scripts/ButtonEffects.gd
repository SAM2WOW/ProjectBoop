extends TextureButton

var tween
func _ready():
	connect("button_down", on_button_down)
	connect("button_up", on_button_up)

	set_pivot_offset(size / 2)


func on_button_down():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	#tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)


func on_button_up():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	#tween.parallel().tween_property(self, "modulate", Color("a68a56"), 0.5)
