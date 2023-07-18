extends CharacterBody3D


const SPEED = 1.0
const RUN_SPEED = 2.0
const ROTATION_SPEED = 10
const JUMP_VELOCITY = 2.5

@export var camera: Node3D
@onready var model: Node3D = get_node("NanahiraPapercraft")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction.length_squared() > 1:
		direction = direction.normalized()
		
	# Hold shift to run
	var held_shift = Input.is_physical_key_pressed(KEY_SHIFT)

	if direction:
		velocity.x = direction.x * (RUN_SPEED if held_shift else SPEED)
		velocity.z = direction.z * (RUN_SPEED if held_shift else SPEED)
		var rotation = Basis(Vector3(0, 1, 0), -atan2(velocity.x, -velocity.z))
		model.global_transform.basis = model.global_transform.basis.slerp(rotation, ROTATION_SPEED * delta)
	else:
		# reset speed to 0
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	model.set_velocity(velocity)
	move_and_slide()
