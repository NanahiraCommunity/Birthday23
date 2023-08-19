extends Node3D

const JUMP_DURATION = 0.4
const JUMP_HEIGHT = 0.1

const WAVE_AMPLITUDE = deg_to_rad(10.0)
# hand waves per second (BPM / 60s)
const WAVE_SPEED = 147.0 / 60.0
const BEAT_DURATION = 1.0 / WAVE_SPEED

const OFFSET = -3.45 - BEAT_DURATION * 4

var bgm: AudioStreamPlayer2D

var states: Array[State]
## Defines in how many groups the NPCs are split - more groups means less NPCs jumping at the same frame, but more lag
@export var num_states: int = 16

class State extends Object:
	var npcs: Array[Node3D] = []
	var hands: Array[Node3D] = []
	var jump_time: float = 0.0
	var time: float = 0.0
	var beat: int = 0

	func ready(bgm):
		time = -bgm.get_playback_position() + randfn(0.0, 0.035) + OFFSET

	func process(delta):
		if jump_time > 0.0:
			var jt = jump_time / JUMP_DURATION
			jump_time -= delta
			var linear = 1.0 - (jt if jt < 0.5 else 1.0 - jt) * 2.0
			var y = linear * linear * JUMP_HEIGHT
			update_y(JUMP_HEIGHT - y)

		time += delta
		var rot = sin(time * PI * 2 * WAVE_SPEED) * WAVE_AMPLITUDE
		update_rot(rot)
		
		if time >= BEAT_DURATION:
			beat += 1
			time -= BEAT_DURATION
			if beat == 4:
				beat = 0
				jump()

	func update_y(y: float):
		for i in range(0, npcs.size()):
			npcs[i].position.y = y
			hands[i].position.y = y

	func update_rot(rot: float):
		for i in range(0, npcs.size()):
			hands[i].rotation.z = rot
			npcs[i].rotation.z = rot * 0.25

	func jump():
		jump_time = JUMP_DURATION

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm = Global.UI.get_bgm()
	states.resize(num_states)
	for i in range(0, num_states):
		states[i] = State.new()
		states[i].ready(bgm)

	for child in get_children():
		if child.is_in_group("audience"):
			var state = randi_range(0, num_states - 1)
			states[state].npcs.append(child.get_body())
			states[state].hands.append(child.get_hands())

func _process(delta):
	for i in range(0, num_states):
		states[i].process(delta)

func add_audience(node):
	add_child(node)
	var state = randi_range(0, num_states - 1)
	states[state].npcs.append(node.get_body())
	states[state].hands.append(node.get_hands())
