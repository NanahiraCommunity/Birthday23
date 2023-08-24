extends Node

var index: int = 0
@onready var streams: Array[Node] = get_children()

func play(sound: AudioStream, from_position: float = 0.0):
	var i = index
	index += 1
	if index >= streams.size():
		index = 0
	streams[i].stream = sound
	streams[i].play(from_position)

# for quests / dialogue
func play_wav(sound: String, from_position: float = 0.0):
	play(load(sound), from_position)
