extends Camera3D

@export var target: Node3D
@export var kinematic_body: CharacterBody3D
@export var min_distance: float = 0.8
@export var max_distance: float = 1.0
@export var height: float = 0.7
@export var speed_height: float = -0.1
@export var min_height_offset: float = -0.6
@export var max_height_offset: float = 1.1

const FOLLOW_SPEED_PUSH = 0.9999
const FOLLOW_SPEED_PULL = 0.85
const ASCEND_SPEED = 0.8
const ASCEND_SPEED_ONGROUND = 0.99
const PREDICTION_SPEED = 0.95
const LOOKAT_SPEED = 0.98
const SPEED_HEIGHT_MULTIPLIER = 30
const PREDICTION_LENGTH = 10
const LOOKAT_OFFSET = Vector3(0, 0.2, 0)
const CAMERA_JOY_DEADZONE = 0.7

var real_pos: Vector3 = Vector3.ZERO
var lookat_pos: Vector3 = Vector3.ZERO
var target_pos: Vector3 = Vector3.ZERO
var camera_position: Vector3 = Vector3.ZERO

var start_rot_joy = NAN
var start_rot_model = NAN
var rot_transition = NAN
var rotate_transition = false
var mouse_drag = Vector2.ZERO
var height_offset = 0
var height_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if target:
		target_pos = target.global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_position = global_position
	
	get_node("/root/SceneSwitcher").curr_camera = self

func _input(event):
	if event is InputEventMouseMotion:
		mouse_drag += event.relative * 0.04

func _process_mouse(delta):
	var dir = Vector2(lookat_pos.x, lookat_pos.z) - Vector2(camera_position.x, camera_position.z)
	var current_rotation = atan2(-dir.y, dir.x)
	
	var joy = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) * 10
	if joy.length_squared() > CAMERA_JOY_DEADZONE * CAMERA_JOY_DEADZONE and target:
		var rot = -atan2(-joy.y, joy.x)
		if is_nan(start_rot_joy):
			start_rot_joy = rot
			start_rot_model = current_rotation
			rot_transition = start_rot_model
		else:
			rot = start_rot_joy - rot + start_rot_model
			rot_transition = lerp_angle(rot_transition, rot, 0.1)
			rotate_transition = true
	else:
		start_rot_joy = NAN
		start_rot_model = NAN

	mouse_drag *= pow(0.1, delta * 10)
	if mouse_drag.length_squared() > 0.01 * 0.01:
		var offset = mouse_drag
		if not rotate_transition:
			rot_transition = current_rotation - offset.x * delta
			rotate_transition = true
		else:
			rot_transition -= offset.x * delta
		height_offset += offset.y * delta
		height_offset = clamp(height_offset, min_height_offset, max_height_offset)
		height_time = 0

	if rotate_transition:
		var rot_diff = fmod(current_rotation - rot_transition + 2 * TAU, TAU)
		if rot_diff > deg_to_rad(0.1) and rot_diff < deg_to_rad(359.9):
			var dist = (Vector2(lookat_pos.x, lookat_pos.z) - Vector2(camera_position.x, camera_position.z)).length()
			camera_position = Vector3(
				lookat_pos.x - cos(rot_transition) * dist,
				camera_position.y,
				lookat_pos.z + sin(rot_transition) * dist)
			solve_constraints()
		else:
			rotate_transition = false

func solve_constraints():
	kinematic_body.global_position = camera_position + Vector3(0, height_offset, 0)
	kinematic_body.move_and_slide()
	global_position = kinematic_body.global_position
	camera_position = global_position - Vector3(0, height_offset, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var speed = Vector3.ZERO
	if target:
		var new_pos = target.global_position
		speed = new_pos - real_pos
		real_pos = new_pos
	var velocity = speed.length()

	_process_mouse(delta)

	height_time += delta
	height_offset *= pow(0.99, height_time)

	target_pos = (target_pos - real_pos) * pow(1 - PREDICTION_SPEED, delta) + real_pos
	lookat_pos = (lookat_pos - real_pos) * pow(1 - LOOKAT_SPEED, delta) + real_pos
	var camera_height = target_pos.y + height + clamp(velocity * SPEED_HEIGHT_MULTIPLIER, 0, 1) * speed_height
	var global_xz = Vector2(camera_position.x, camera_position.z)
	var predicted_pos = target_pos + speed * PREDICTION_LENGTH
	var target_xz = Vector2(predicted_pos.x, predicted_pos.z)
	
	var min_dist = min_distance * lerp(1.0, 10.0, velocity)
	var max_dist = max_distance * lerp(1.0, 1.5, velocity)

	var dist = global_xz.distance_squared_to(target_xz)
	var dir = (global_xz - target_xz).normalized()
	if dist < min_dist * min_dist:
		var push_xz = target_xz + dir * min_dist
		camera_position.x = (camera_position.x - push_xz.x) * pow(1 - FOLLOW_SPEED_PUSH, delta) + push_xz.x
		camera_position.z = (camera_position.z - push_xz.y) * pow(1 - FOLLOW_SPEED_PUSH, delta) + push_xz.y
	elif dist > max_dist * max_dist:
		var pull_xz = target_xz + dir * max_dist
		camera_position.x = (camera_position.x - pull_xz.x) * pow(1 - FOLLOW_SPEED_PULL, delta) + pull_xz.x
		camera_position.z = (camera_position.z - pull_xz.y) * pow(1 - FOLLOW_SPEED_PULL, delta) + pull_xz.y

	var ascend_speed = ASCEND_SPEED_ONGROUND if target && target.is_on_floor() else ASCEND_SPEED
	camera_position.y = (camera_position.y - camera_height) * pow(1 - ascend_speed, delta) + camera_height

	solve_constraints()

	look_at(lookat_pos + LOOKAT_OFFSET)
