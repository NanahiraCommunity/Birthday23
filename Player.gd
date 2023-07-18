extends CharacterBody3D


const WALK_SPEED = 0.75
const RUN_SPEED = 1.5
const ROTATION_SPEED = 10
const JUMP_VELOCITY = 2.5
const STOP_SPEED = 0.15

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
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	if direction.length_squared() > 1:
		direction = direction.normalized()
	direction = camera.transform.basis * direction;

	if direction:
		var sneak = Input.is_action_pressed("sneak")
		velocity.x = direction.x * (WALK_SPEED if sneak else RUN_SPEED)
		velocity.z = direction.z * (WALK_SPEED if sneak else RUN_SPEED)
		var rotation = Basis(Vector3(0, 1, 0), -atan2(velocity.x, -velocity.z))
		model.global_transform.basis = model.global_transform.basis.slerp(rotation, ROTATION_SPEED * delta)
	else:
		# reset speed to 0
		velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		velocity.z = move_toward(velocity.z, 0, STOP_SPEED)

	model.set_velocity(velocity)
	move_and_slide()
