extends Node3D

const JUMP_DURATION = 0.4
const JUMP_HEIGHT = 0.1

const WAVE_AMPLITUDE = deg_to_rad(10.0)
# hand waves per second (BPM / 60s)
const WAVE_SPEED = 147.0 / 60.0
const BEAT_DURATION = 1.0 / WAVE_SPEED

const OFFSET = -3.45 - BEAT_DURATION * 4

var jump_time: float = 0.0
var time: float = 0.0
var beat: int = 0

var bgm: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm = Global.UI.get_bgm()
	time = -bgm.get_playback_position() + randfn(0.0, 0.035) + OFFSET

func _process(delta):
	if jump_time > 0.0:
		var jt = jump_time / JUMP_DURATION
		jump_time -= delta
		var linear = 1.0 - (jt if jt < 0.5 else 1.0 - jt) * 2.0
		var y = linear * linear * JUMP_HEIGHT
		$GenericNpc.position.y = JUMP_HEIGHT - y
		$GenericNpcHands.position.y = JUMP_HEIGHT - y

	time += delta
	var rot = sin(time * PI * 2 * WAVE_SPEED) * WAVE_AMPLITUDE
	$GenericNpcHands.rotation.z = rot
	$GenericNpc.rotation.z = rot * 0.25
	
	if time >= BEAT_DURATION:
		beat += 1
		time -= BEAT_DURATION
		if beat == 4:
			beat = 0
			jump()

func jump():
	jump_time = JUMP_DURATION
