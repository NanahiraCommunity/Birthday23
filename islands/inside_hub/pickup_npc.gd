extends "res://npc_character.gd"

const SPEED = 1.2
const ROTATION_SPEED = 10
const STUCK_TIME_THRESHOLD = 5.0
const STUCK_MARGIN = 0.01
const TARGET_GOAL_DISTANCE = 0.3

@onready var model: Node3D = get_node("nanahira_papercraft")

signal reached_target

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _target: Node3D = null
var timeout: float = 0.0

var stuck_time: float = 0.0
var stuck_pos: Vector3 = Vector3.ZERO

func _ready():
	$NavigationAgent3D.process_mode = Node.PROCESS_MODE_INHERIT
	NavigationServer3D.agent_set_avoidance_enabled($NavigationAgent3D.get_rid(), true)
	$NavigationAgent3D.avoidance_enabled = true
	$NavigationAgent3D.velocity_computed.connect(Callable(_on_velocity_computed))
	$NavigationAgent3D.navigation_finished.connect(Callable(_navigation_finished))
	
	set_target(Global.player)

func set_target(node: Node3D):
	var start = global_position
	var navmap = get_world_3d().navigation_map
	_target = node
	$NavigationAgent3D.target_position = node.global_position

func _process(delta):
	super._process(delta)
	if _target:
		if timeout < 0:
			timeout = 0.7
			set_target(_target)
		else:
			timeout -= delta
			
		if global_position.distance_squared_to($NavigationAgent3D.get_final_position()) < TARGET_GOAL_DISTANCE * TARGET_GOAL_DISTANCE:
			set_target(_target)
			await $NavigationAgent3D.path_changed
			if global_position.distance_squared_to(_target.global_position) < TARGET_GOAL_DISTANCE * TARGET_GOAL_DISTANCE:
				_navigation_finished()

		if not $NavigationAgent3D.is_navigation_finished():
			if global_position.distance_squared_to(stuck_pos) >= STUCK_MARGIN * STUCK_MARGIN:
				stuck_time = 0
				stuck_pos = global_position
			else:
				stuck_time += delta

			if stuck_time > STUCK_TIME_THRESHOLD:
				global_position = $NavigationAgent3D.get_next_path_position()
				$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var ai_velocity = velocity

	if not $NavigationAgent3D.is_navigation_finished():
		var next: Vector3 = $NavigationAgent3D.get_next_path_position()
		var movement = (next - global_position).normalized() * SPEED
		ai_velocity.x = movement.x
		ai_velocity.z = movement.z
		$NavigationAgent3D.set_velocity(ai_velocity)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
	model.set_velocity(velocity)
	update_rotation(delta)

func _navigation_finished():
	$NavigationAgent3D.target_position = global_position
	_target = null
	reached_target.emit()

func _on_velocity_computed(safe_velocity: Vector3):
	print(safe_velocity)
	velocity = safe_velocity
	move_and_slide()

func update_rotation(delta):
	# code below copied from player.gd, TODO: abstract this away
	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		global_transform.basis = global_transform.basis.slerp(target_rotation, ROTATION_SPEED * delta)
