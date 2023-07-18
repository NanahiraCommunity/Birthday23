extends Camera3D

@export var target: Node3D
@export var min_distance: float = 0.8
@export var max_distance: float = 1.0
@export var height: float = 0.7
@export var speed_height: float = -0.1

const FOLLOW_SPEED_PUSH = 0.9999
const FOLLOW_SPEED_PULL = 0.85
const ASCEND_SPEED = 0.8
const ASCEND_SPEED_ONGROUND = 0.99
const PREDICTION_SPEED = 0.95
const LOOKAT_SPEED = 0.98
const SPEED_HEIGHT_MULTIPLIER = 30
const PREDICTION_LENGTH = 10
const LOOKAT_OFFSET = Vector3(0, 0.2, 0)

var real_pos: Vector3 = Vector3.ZERO
var lookat_pos: Vector3 = Vector3.ZERO
var target_pos: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	if target:
		target_pos = target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var speed = Vector3.ZERO
	if target:
		var new_pos = target.global_position
		speed = new_pos - real_pos
		real_pos = new_pos
	var velocity = speed.length()

	target_pos = (target_pos - real_pos) * pow(1 - PREDICTION_SPEED, delta) + real_pos
	lookat_pos = (lookat_pos - real_pos) * pow(1 - LOOKAT_SPEED, delta) + real_pos
	var camera_height = target_pos.y + height + clamp(velocity * SPEED_HEIGHT_MULTIPLIER, 0, 1) * speed_height
	var global_xz = Vector2(global_position.x, global_position.z)
	var predicted_pos = target_pos + speed * PREDICTION_LENGTH
	var target_xz = Vector2(predicted_pos.x, predicted_pos.z)
	
	var min_dist = min_distance * lerp(1.0, 10.0, velocity)
	var max_dist = max_distance * lerp(1.0, 1.5, velocity)

	var dist = global_xz.distance_squared_to(target_xz)
	var dir = (global_xz - target_xz).normalized()
	if dist < min_dist * min_dist:
		var push_xz = target_xz + dir * min_dist
		global_position.x = (global_position.x - push_xz.x) * pow(1 - FOLLOW_SPEED_PUSH, delta) + push_xz.x
		global_position.z = (global_position.z - push_xz.y) * pow(1 - FOLLOW_SPEED_PUSH, delta) + push_xz.y
	elif dist > max_dist * max_dist:
		var pull_xz = target_xz + dir * max_dist
		global_position.x = (global_position.x - pull_xz.x) * pow(1 - FOLLOW_SPEED_PULL, delta) + pull_xz.x
		global_position.z = (global_position.z - pull_xz.y) * pow(1 - FOLLOW_SPEED_PULL, delta) + pull_xz.y

	var ascendSpeed = ASCEND_SPEED_ONGROUND if target && target.is_on_floor() else ASCEND_SPEED
	global_position.y = (global_position.y - camera_height) * pow(1 - ascendSpeed, delta) + camera_height
	look_at(lookat_pos + LOOKAT_OFFSET)
