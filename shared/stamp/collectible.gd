extends Node3D

const ROTATE_SPEED = 0.9
const FLOAT_SPEED = 1.3
const FLOAT_AMPLITUDE = 0.05

const PICKUP_DISTANCE = 0.2
const Y_MIN = 0.0
const Y_MAX = 0.28

var t = 0.0

var value = 1

var base_scale = 1.0

func _ready():
	t = fmod(global_position.x + global_position.z, TAU)
	rotate_y(t)
	$GlowShape.material_override = $GlowShape.material.duplicate()

	var depth = 1.0
	if value == 1:
		base_scale = 0.75
	else:
		base_scale = 1.5
		depth = 3.0
	$Confetto.scale = Vector3(base_scale, base_scale, base_scale * depth)

func _physics_process(delta):
	rotate_y(delta * ROTATE_SPEED)
	t += delta * FLOAT_SPEED
	if t > TAU:
		t -= TAU
	$Confetto.position.y = sin(t) * FLOAT_AMPLITUDE

	var player = Global.player.global_position
	var pos = global_position
	var dx = pos.x - player.x;
	var dz = pos.z - player.z;
	var d = dx * dx + dz * dz
	glow_scale(d)
	if d < PICKUP_DISTANCE * PICKUP_DISTANCE:
		var min_pickup = pos.y - PICKUP_DISTANCE
		var max_pickup = pos.y + PICKUP_DISTANCE
		var min_player = player.y + Y_MIN
		var max_player = player.y + Y_MAX
		if not (max_player < min_pickup or min_player > max_pickup):
			collect()

func collect():
	queue_free()

func glow_scale(s: float):
	s = clamp(s * 0.05, 1.0, 1.5) * base_scale
	$GlowShape.scale = Vector3(s, s, s)
	$GlowShape.material_override.set_shader_parameter("glow_size", s * 0.17);
