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
	match (state):
		IDLE:
			idle()
		WALKING:
			walk()
		FLYING:
			fly()
		TALKING:
			talk()

func idle():
	if Global.in_dialog:
		state = TALKING
		talk()
		return
		
	if direction.length():
		state = WALKING
		print("changed to walk")
		walk()
		return
	
	
	
func walk():
	# Not sure where dialog is being handled
	# idk if jumping from walking to a dialog
	# is even possible. Put this here jic
	if Global.in_dialog:
		state = TALKING
		talk()
		return
		
	
	return

func fly():
	return

func talk():
	return


