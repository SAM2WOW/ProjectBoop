extends Sprite2D

var tween
var star = preload("res://scenes/Star.tscn")
var heart = preload("res://scenes/Heart.tscn")

var initial_point = Vector2.ZERO
var check = false
var pull = false
var pull_horizontal = true
var pull_distance = 10.0

enum STATE {PUSH, NORMAL, PULL}
var current_state = STATE.NORMAL

var petting = false
var petting_raw = 0.0
var petting_scale = 0.0
var in_headspace = false

var tapping = 0
var happiness = 0.0
var happy = false

var speech = [
	"Don't forget to drink water!",
	"Stay hydrated!",
]

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			initial_point = get_global_mouse_position()
			
			check = true
	
	if event is InputEventMouseMotion:
		if petting:
			#print("petting - %f" % event.get_relative().length())
			petting_raw = event.get_relative().length()
		
		if check:
			if get_global_mouse_position().distance_to(initial_point) > pull_distance:
				var s = star.instantiate()
				$Area2D.add_child(s)
				s.set_global_position(get_global_mouse_position())
				
				check = false
				pull = true
				petting = false
				
				var vector = get_global_mouse_position() - initial_point
				pull_horizontal = (abs(vector.x) > abs(vector.y))
				print("Direction checked: %d : %d" % [abs(vector.x), abs(vector.y)])
				print(pull_horizontal)
				
				$"../Hand".set_state(1)
				SoundPlayer.play("Grab")

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			check = false
			
			if pull:
				pull = false
				
				$"../Hand".set_state(0)
				
				if tween:
					tween.kill()
				tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
				
				if pull_horizontal:
					SoundPlayer.play("Bounce1")
				else:
					SoundPlayer.play("Bounce2")
			else:
				if not get_viewport().is_input_handled():
					boop()
					
					var s = star.instantiate()
					get_parent().add_child(s)
					s.set_global_position(get_global_mouse_position())


func boop():
	# Booping
	print("Boop")
	
	# check if in head space, if so verticle boop
	if in_headspace:
		set_scale(Vector2(1, 0.7))	
		#if scale.x < 1.05 and scale.x > 0.95:
	else:
		set_scale(Vector2(0.7, 1))
	
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	
	SoundPlayer.play(["Press", "Press2"][randi() % 2])
	
	tapping += 1
	print(tapping)
	if tapping == SaveSystem.settings.BoopCount:
		tapping = 0
		speaking()
	
	# decrease happiness for booping
	happiness = max(happiness - 0.1, 0.0)
	if happy and happiness <= 0.3:
		happy = false
		$Area2D/HappyParticle.set_emitting(false)
		$Area2D/HappyParticle2.set_emitting(false)
		$Area2D/HappyParticle3.set_emitting(false)

func speaking():
	# check if can speak
	if not SaveSystem.settings.Popups:
		return
	
	var speech = $"..".speech_list[$"..".character_list[$"..".current_character]]
	if speech.is_empty():
		print($"..".speech_list[$"..".character_list[$"..".current_character]])
		return
	
	#$"../Textbox/VBoxContainer/RichTextLabel".set_text("[center]%s[/center]" % speech[randi() % len(speech)])
	$"../Textbox/VBoxContainer/RichTextLabel".set_text("[center]%s[/center]" % speech[randi() % len(speech)])
	$"../AnimationPlayer".stop()
	$"../AnimationPlayer".play("speaking")
	
	#SoundPlayer.play(["Kirin1", "Kirin2", "Kirin3", "Kirin4"][randi() % 4])
	SoundPlayer.speak()


func _process(delta):
	# change the petting scale value
	petting_scale = lerp(petting_scale, clamp(petting_raw / 20.0, 0.0, 1.0) * int(petting), delta * 20)
	#print(petting_scale)
	
	# move down character if in head space
	set_offset(lerp(get_offset(), Vector2(0, -512 + 15 * int(petting) + 30 * petting_scale), delta * 20))
	$FaceShadow.set_offset(lerp($FaceShadow.get_offset(), Vector2(0, -256 + 30 * petting_scale), delta * 20))
	
	# check pating with cooldown
	if petting_scale > 0.5 and $"../PetTimer".is_stopped():
		print("PET")
		$"../PetTimer".start()
		
		var pat_sound = ["Pat1", "Pat2", "Pat3", "Pat4"][randi() % 4]
		SoundPlayer.play(pat_sound, petting_scale)
		
		var h = heart.instantiate()
		get_parent().add_child(h)
		h.set_global_position(get_global_mouse_position() + Vector2(0, 30))
		
		happiness = min(happiness + 0.06, 1.0)
		
		if not happy and happiness > 0.7:
			happy = true
			print("ENTER HAPPY")
			$Area2D/HappyParticle.set_emitting(true)
			$Area2D/HappyParticle2.set_emitting(true)
			$Area2D/HappyParticle3.set_emitting(true)
			
			SoundPlayer.speak()
			SoundPlayer.play("Happy")
			
			var h2 = heart.instantiate()
			get_parent().add_child(h2)
			h2.set_global_position($Area2D.get_global_position())
	
	# slowly decrease happy
	happiness = max(happiness - delta * 0.05, 0.0)
	#print(happiness)
	if happy and happiness <= 0.3:
		happy = false
		$Area2D/HappyParticle.set_emitting(false)
		$Area2D/HappyParticle2.set_emitting(false)
		$Area2D/HappyParticle3.set_emitting(false)
	
	# detecting for global hotkey input
	if GlobalInput.is_action_just_pressed("Boop"):
		if bool(SaveSystem.settings.BoopKeyToggle):
			boop()
			
			var s = star.instantiate()
			get_parent().add_child(s)
			s.set_global_position($Area2D.get_global_position())
	
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


func _on_headspace_mouse_entered():
	in_headspace = true
	if not pull:
		petting = true
		
		$"../Hand".set_state(2)


func _on_headspace_mouse_exited():
	in_headspace = false
	if not pull:
		petting = false
		
		$"../Hand".set_state(0)
