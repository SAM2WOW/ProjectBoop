extends Sprite2D

var tween
var start = preload("res://Star.tscn")

var initial_point = Vector2.ZERO
var pull = false

enum STATE {PUSH, NORMAL, PULL}
var current_state = STATE.NORMAL


var tapping = 0

var speech = [
	"Don't forget to drink water!",
	"Stay hydrated!",
	"Blep",
	"STAP!!!!!",
	"I can tank this",
	"IM GONNA GET YOU",
	"GRAB YOU",
]

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			initial_point = get_global_mouse_position()
			pull = true
			

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			pull = false
			
			if scale.x < 1.05 and scale.x > 0.95:
				set_scale(Vector2(0.7, 1))
			#set_position(Vector2(179, 256))
			
			if tween:
				tween.kill()
			tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
			
			SoundPlayer.play(["Press", "Press2"][randi() % 2])
			
			tapping += 1
			if tapping == 10:
				$"../Textbox/VBoxContainer/RichTextLabel".set_text(speech[randi() % len(speech)])
				$"../AnimationPlayer".play("speaking")
				tapping = 0
				
				SoundPlayer.play(["Kirin1", "Kirin2", "Kirin3", "Kirin4"][randi() % 4])
			
			var s = start.instantiate()
			$Area2D.add_child(s)
			s.set_global_position(get_global_mouse_position())


func _process(delta):
	if pull:
		var distance = (get_global_mouse_position().x - initial_point.x)
		var new_x = lerp(1.0, 1.5, distance / 234.0)
		new_x = clamp(new_x, 0.1, 1.4)
		
		set_scale(Vector2(new_x, 1))
		
		if new_x > 1.2:
			if current_state != STATE.PULL:
				current_state = STATE.PULL
				SoundPlayer.play("Pull")
		elif new_x < 0.3:
			if current_state != STATE.PUSH:
				current_state = STATE.PUSH
				SoundPlayer.play("Squish")
		else:
			current_state = STATE.NORMAL


func _on_animation_player_animation_finished(anim_name):
	if "speaking" in anim_name:
		$"../AnimationPlayer".play("Idle")
