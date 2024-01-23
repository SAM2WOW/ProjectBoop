extends Node


var sounds = {
	"Press": "Press.wav",
	"Press2": "Press2.wav",
	"Pull": "Pull.wav",
	"Squish": "squish.wav",
	"UI": "Touch.wav",
	"Button": "Button.wav"
}

var speech = []


func _ready():
	for i in sounds.keys():
		var s = AudioStreamPlayer.new()
		var script = load("res://scripts/AudioRandomizer.gd")
		s.set_stream(load("res://sounds/%s" % sounds[i]))
		s.set_bus("Sound")
		s.set_script(script)
		s.name = i
		add_child(s)


func add_speech(path):
	var s = AudioStreamPlayer.new()
	var audio_loader = AudioLoader.new()
	s.set_stream(audio_loader.loadfile(path))
	s.set_bus("Sound")
	
	#var script = load("res://scripts/AudioRandomizer.gd")
	#s.set_script(script)
	
	add_child(s)
	speech.append(s)


func clear_speech():
	for i in speech:
		i.queue_free()
	
	speech.clear()


func play(sound_name):
	get_node(sound_name).play()


func speak():
	if not speech.is_empty():
		speech[randi() % len(speech)].play()
