extends CharacterBody3D


const WALK_SPEED = 0.75
const RUN_SPEED = 1.5
const ROTATION_SPEED = 10
const JUMP_VELOCITY = 3.5
const FLIGHT_VELOCITY_UP = 1.5
const FLIGHT_VELOCITY_FORWARD = 3.0
const WALK_AIR_SPEED_MULTIPLIER = 0.7
const FLYING_AIR_SPEED_MULTIPLIER = 1.0
const STOP_SPEED = 0.25

const FLY_START_ANIMATION_SPEED = 10.0
const FLY_END_ANIMATION_SPEED = 30.0
const FLIGHT_DRAG_VERTICAL = 0.5
const FLIGHT_DRAG_HORIZONTAL = 0.99

@export var camera: Node3D
@onready var model: Node3D = get_node("nanahira_papercraft")
@onready var skeleton: Skeleton3D = model.get_node("Armature/Skeleton3D")
@onready var root_bone: int = skeleton.find_bone("Root")

var flying = false
var flight_strokes_max = 3
var flight_strokes = flight_strokes_max
var flight_stroke_timer_max = 0.3
var flight_stroke_timer = flight_stroke_timer_max

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var flight_gravity = gravity * 0.1

var start_jump = false

func _visualize_flight(delta):
	#var bonePose = skeleton.get_bone_pose(root_bone)
	#var targetPose = skeleton.get_bone_pose_rotation(root_bone)
	#if flying:
	#	targetPose = targetPose.slerp(Quaternion(Vector3(1.0, 0.0, 0.0), deg_to_rad(-70.0)), FLY_START_ANIMATION_SPEED * delta)
	#else:
	#	targetPose = targetPose.slerp(Quaternion(skeleton.get_bone_rest(root_bone).basis), FLY_END_ANIMATION_SPEED * delta)
	#skeleton.set_bone_pose_rotation(root_bone, targetPose)
	model.set_flight(flying)

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		start_jump = true

func _physics_process(delta):
	if Global.in_dialog:
		model.set_velocity(Vector3.ZERO)
		return # we just skip player physics in dialog for now
	
	var on_floor = is_on_floor()

	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	if direction.length_squared() > 1:
		direction = direction.normalized()
	direction = camera.transform.basis * direction;

	if not on_floor:
		if flying:
			if start_jump && flight_strokes > 0 && flight_stroke_timer < 0:
				flight_strokes -= 1
				velocity.y = FLIGHT_VELOCITY_UP
				velocity.x = FLIGHT_VELOCITY_FORWARD * direction.x
				velocity.z = FLIGHT_VELOCITY_FORWARD * direction.z
				flight_stroke_timer = flight_stroke_timer_max
			else:
				velocity.y -= (flight_gravity if Input.is_action_pressed("jump") else gravity) * delta
				velocity.x *= pow(FLIGHT_DRAG_HORIZONTAL, delta)
				velocity.z *= pow(FLIGHT_DRAG_HORIZONTAL, delta)
				velocity.y *= pow(FLIGHT_DRAG_VERTICAL, delta)

			flight_stroke_timer -= delta
		else:
			if start_jump:
				flying = true
				flight_strokes = flight_strokes_max
				flight_stroke_timer = 0
				velocity.y = FLIGHT_VELOCITY_UP
				velocity.x = FLIGHT_VELOCITY_FORWARD * direction.x
				velocity.z = FLIGHT_VELOCITY_FORWARD * direction.z
			else:
				velocity.y -= gravity * delta

		if direction:
			var sneak = Input.is_action_pressed("sneak")
			var speed_multiplier = FLYING_AIR_SPEED_MULTIPLIER if flying else WALK_AIR_SPEED_MULTIPLIER
			velocity.x = direction.x * (WALK_SPEED if sneak else RUN_SPEED) * speed_multiplier
			velocity.z = direction.z * (WALK_SPEED if sneak else RUN_SPEED) * speed_multiplier
	else:
		if flying:
			flying = false

		if start_jump:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y -= gravity * delta

		if direction:
			var sneak = Input.is_action_pressed("sneak")
			velocity.x = direction.x * (WALK_SPEED if sneak else RUN_SPEED)
			velocity.z = direction.z * (WALK_SPEED if sneak else RUN_SPEED)
		else:
			# reset speed to 0
			velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
			velocity.z = move_toward(velocity.z, 0, STOP_SPEED)

	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		global_transform.basis = global_transform.basis.slerp(target_rotation, ROTATION_SPEED * delta)

	start_jump = false

	model.set_velocity(velocity)
	move_and_slide()

	_visualize_flight(delta)
