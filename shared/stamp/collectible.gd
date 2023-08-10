extends Node3D

const ROTATE_SPEED = 0.9
const FLOAT_SPEED = 1.3
const FLOAT_AMPLITUDE = 0.05

const PICKUP_DISTANCE = 0.2
const Y_MIN = 0.0
const Y_MAX = 0.36

var t = 0.0

var test_index = 0

func _ready():
	test_index = randi_range(0, 2)

func _process(delta):
	rotate_y(delta * ROTATE_SPEED)
	t += delta * FLOAT_SPEED
	if t > TAU:
		t -= TAU
	$Confetto.position.y = sin(t) * FLOAT_AMPLITUDE
	if test_index == 0:
		var player = Global.player.global_position
		var pos = global_position
		var dx = pos.x - player.x;
		var dz = pos.z - player.z;
		if dx * dx + dz * dz < PICKUP_DISTANCE * PICKUP_DISTANCE:
			var min_pickup = pos.y - PICKUP_DISTANCE
			var max_pickup = pos.y + PICKUP_DISTANCE
			var min_player = player.y + Y_MIN
			var max_player = player.y + Y_MAX
			if not (max_player < min_pickup or min_player > max_pickup):
				collect()
		test_index = 2
	else:
		test_index -= 1

func collect():
	queue_free()
