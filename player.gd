extends CharacterBody3D


const WALK_SPEED = 0.75
const RUN_SPEED = 1.5
const ROTATION_SPEED = 10
const JUMP_VELOCITY = 3.5
const FLIGHT_VELOCITY_UP = 1.5
const FLIGHT_VELOCITY_FORWARD = 1.0
const WALK_AIR_SPEED_MULTIPLIER = 0.12
const FLYING_AIR_SPEED_MULTIPLIER = 0.15
const STOP_SPEED = 0.25

const FLY_START_ANIMATION_SPEED = 10.0
const FLY_END_ANIMATION_SPEED = 30.0
const FLIGHT_DRAG_VERTICAL = 0.5
const FLIGHT_DRAG_HORIZONTAL = 0.01

@export var camera: Node3D
@onready var model: Node3D = get_node("nanahira_papercraft")
@onready var skeleton: Skeleton3D = model.get_node("Armature/Skeleton3D")
@onready var root_bone: int = skeleton.find_bone("Root")

func _ready():
	Global.player = self

var flying = false
var flight_strokes_max = 3
var flight_strokes = flight_strokes_max
var flight_stroke_timer_max = 0.3
var flight_stroke_timer = flight_stroke_timer_max

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var flight_gravity = gravity * 0.1

var start_jump = false
var direction = Vector3(0, 0, 0)
var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
var sneak = false
var is_jumping = false

enum {
	IDLE,
	WALKING,
	JUMPING,
	FLYING,
	TALKING
}
var state = IDLE

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
	input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	direction = Vector3(input_dir.x, 0, input_dir.y)
	sneak = Input.is_action_pressed("sneak")
	is_jumping = Input.is_action_pressed("jump")
	match (state):
		IDLE:
			idle(delta)
		WALKING:
			walk(delta)
		JUMPING:
			jump(delta)
		FLYING:
			fly(delta)
		TALKING:
			talk(delta)
	
	model.set_velocity(velocity)
	move_and_slide()
	_visualize_flight(delta)


func idle(delta):	
	if Global.in_dialog:
		state = TALKING
		talk(delta)
		return
		
	if direction.length():
		state = WALKING
		walk(delta)
		return
	
	velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
	velocity.z = move_toward(velocity.z, 0, STOP_SPEED)
	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		global_transform.basis = global_transform.basis.slerp(target_rotation, ROTATION_SPEED * delta)
	
	
func walk(delta):
	# Not sure where dialog is being handled
	# idk if going from walking to a entering a dialog
	# is even possible but I put this here jic
	if Global.in_dialog:
		state = TALKING
		talk(delta)
		return
		
	if is_jumping:
		state = JUMPING
		jump(delta)
		return
		
	if not direction:
		state = IDLE
		idle(delta)
		return
	direction = camera.transform.basis * direction;
	
	velocity.x = direction.x * (WALK_SPEED if sneak else RUN_SPEED)
	velocity.z = direction.z * (WALK_SPEED if sneak else RUN_SPEED)
	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		global_transform.basis = global_transform.basis.slerp(target_rotation, ROTATION_SPEED * delta)

func jump(delta):
	return

func fly(delta):
	return

func talk(delta):
	return


