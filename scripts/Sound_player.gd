extends Node


var sounds = {
	"Press": "Press.wav",
	"Press2": "Press2.wav",
	"Pull": "Pull.wav",
	"Squish": "squish.wav",
	"Kirin1": "Kirin1.wav",
	"Kirin2": "Kirin2.wav",
	"Kirin3": "Kirin3.wav",
	"Kirin4": "Kirin4.wav",
}


func _ready():
	for i in sounds.keys():
		var s = AudioStreamPlayer.new()
		var script = load("res://scripts/AudioRandomizer.gd")
		s.set_stream(load("res://sounds/%s" % sounds[i]))
		s.set_bus("Sound")
		s.set_script(script)
		s.name = i
		add_child(s)


func play(sound_name):
	get_node(sound_name).play()
