extends Sprite2D

var tween
var start = preload("res://Star.tscn")

var initial_point = Vector2.ZERO
var check = false
var pull = false
var pull_horizontal = true
var pull_distance = 10.0

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
	"You're alive!",
	"I live here rent free",
	"Don't die",
	"Fuck around and find out",
	"This is not ideal",
	"We take those",
]

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			initial_point = get_global_mouse_position()
			
			check = true
	
	if event is InputEventMouseMotion:
		if check:
			if get_global_mouse_position().distance_to(initial_point) > pull_distance:
				var s = start.instantiate()
				$Area2D.add_child(s)
				s.set_global_position(get_global_mouse_position())
				
				check = false
				pull = true
				
				var vector = get_global_mouse_position() - initial_point
				pull_horizontal = (abs(vector.x) > abs(vector.y))
				print("Direction checked: %d : %d" % [abs(vector.x), abs(vector.y)])
				print(pull_horizontal)


func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			check = false
			
			if pull:
				pull = false
				
				if tween:
					tween.kill()
				tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
			else:
				# Booping
				print("Boop")
				if scale.x < 1.05 and scale.x > 0.95:
					set_scale(Vector2(0.7, 1))
				
				if tween:
					tween.kill()
				tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
				
				SoundPlayer.play(["Press", "Press2"][randi() % 2])
				
				tapping += 1
				if tapping == 10:
					speaking()
				
				var s = start.instantiate()
				$Area2D.add_child(s)
				s.set_global_position(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Boop"):
		print("Boop")
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
			speaking()
		
		var s = start.instantiate()
		$Area2D.add_child(s)


func speaking():
	if $"..".speech_list.is_empty():
		return
	
	#$"../Textbox/VBoxContainer/RichTextLabel".set_text("[center]%s[/center]" % speech[randi() % len(speech)])
	$"../Textbox/VBoxContainer/RichTextLabel".set_text("[center]%s[/center]" % $"..".speech_list[randi() % len($"..".speech_list)])
	$"../AnimationPlayer".stop()
	$"../AnimationPlayer".play("speaking")
	tapping = 0
	
	#SoundPlayer.play(["Kirin1", "Kirin2", "Kirin3", "Kirin4"][randi() % 4])
	SoundPlayer.speak()

func _process(delta):
	if pull:
		if pull_horizontal:
			#var distance = initial_point.distance_to(get_global_mouse_position())
			var distance = get_global_mouse_position().x - initial_point.x
			
			var new_x = lerp(1.0, 1.5, distance / 234.0)
			new_x = clamp(new_x, 0.1, 2)
			
			set_scale(lerp(get_scale(), Vector2(new_x, 1), delta * 20))
			
			if new_x > 1.5:
				if current_state != STATE.PULL:
					current_state = STATE.PULL
					SoundPlayer.play("Pull")
			elif new_x < 0.5:
				if current_state != STATE.PUSH:
					current_state = STATE.PUSH
					SoundPlayer.play("Squish")
			else:
				current_state = STATE.NORMAL
		
		else:
			var distance = get_global_mouse_position().y - initial_point.y
			
			var new_y = lerp(0.5, 1.0, 1.0 - (distance / 234.0))
			new_y = clamp(new_y, 0.1, 1)
			
			set_scale(lerp(get_scale(), Vector2(1, new_y), delta * 20))
			
			if new_y > 0.8:
				if current_state != STATE.PULL:
					current_state = STATE.PULL
					SoundPlayer.play("Pull")
			elif new_y < 0.4:
				if current_state != STATE.PUSH:
					current_state = STATE.PUSH
					SoundPlayer.play("Squish")
			else:
				current_state = STATE.NORMAL

func _on_animation_player_animation_finished(anim_name):
	if "speaking" in anim_name:
		$"../AnimationPlayer".play("Idle")
	if "spawn" in anim_name:
		$"../AnimationPlayer".play("Idle")
