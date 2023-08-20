extends CharacterBody3D


const WALK_SPEED = 0.75
const RUN_SPEED = 1.5
const ROTATION_SPEED = 10
const JUMP_VELOCITY = 3.2
const FLIGHT_VELOCITY_UP = 1.5
const FLIGHT_START_VELOCITY_UP = 1.2
const FLIGHT_VELOCITY_FORWARD = 1.0
const WALK_AIR_SPEED_MULTIPLIER = 0.12
const FLYING_AIR_SPEED_MULTIPLIER = 0.15
const STOP_SPEED = 0.25
# how wide a step needs to be to auto-walk up
const MIN_STEP_WIDTH = 0.08
# how high a step can be at most to auto-walk up
const MAX_STEP_HEIGHT = 0.115
const STEP_UP_FORCE = 1.4

const FLY_START_ANIMATION_SPEED = 10.0
const FLY_END_ANIMATION_SPEED = 30.0
const FLIGHT_DRAG_VERTICAL = 0.5
const FLIGHT_DRAG_HORIZONTAL = 0.01

@export var camera: Node3D
@onready var model: Node3D = $NanahiraPapercraft
@onready var skeleton: Skeleton3D = model.get_node("Armature/Skeleton3D")
@onready var root_bone: int = skeleton.find_bone("Root")

var oob_height: float = -20

func _ready():
	Global.player = self

func _enter_tree():
	await get_tree().process_frame
	var oobnode = get_tree().current_scene.get_node_or_null("OOBHeight")
	if oobnode:
		oob_height = oobnode.global_position.y

var flight_strokes_max = 2
var flight_strokes = flight_strokes_max
var flight_stroke_timer_first = 0.2
var flight_stroke_timer_max = 0.3
var flight_stroke_timer = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var slowfall_gravity = gravity * 0.7
var flight_gravity = gravity * 0.1

var start_jump = false
var direction = Vector3(0, 0, 0)
var input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
var sneak = false
var jump_held = false
var jump_pressed
var on_floor = false
var is_stair_stepping = false

enum {
	IDLE,
	WALKING,
	JUMPING,
	FLYING,
	TALKING
}
var state = IDLE

func _visualize_flight(delta, is_flying):
	#var bonePose = skeleton.get_bone_pose(root_bone)
	#var targetPose = skeleton.get_bone_pose_rotation(root_bone)
	#if flying:
	#	targetPose = targetPose.slerp(Quaternion(Vector3(1.0, 0.0, 0.0), deg_to_rad(-70.0)), FLY_START_ANIMATION_SPEED * delta)
	#else:
	#	targetPose = targetPose.slerp(Quaternion(skeleton.get_bone_rest(root_bone).basis), FLY_END_ANIMATION_SPEED * delta)
	#skeleton.set_bone_pose_rotation(root_bone, targetPose)
	model.set_flight(is_flying)

func reset():
	state = IDLE
	model.set_velocity(Vector3.ZERO)
	model.set_flight(false)

func _physics_process(delta):
	var gpos = global_position
	RenderingServer.global_shader_parameter_set("player_world_position", gpos)
	if gpos.y < oob_height:
		animate_oob()

	sneak = Input.is_action_pressed("sneak")
	jump_held = Input.is_action_pressed("jump")
	jump_pressed = Input.is_action_just_pressed("jump")
	on_floor = is_on_floor()
	input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = camera.transform.basis * direction
	match (state):
		IDLE:
			idle(delta)
		WALKING:
			walk(delta)
		JUMPING:
			jump(delta)
		FLYING:
			fly(delta, false)
		TALKING:
			talk(delta)

	# Model rotation
	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		global_transform.basis = global_transform.basis.slerp(target_rotation, ROTATION_SPEED * delta)

	if move_and_slide():
		if Global.neko_world:
			for i in range(0, get_slide_collision_count()):
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider.has_method("is_in_group") and collider.is_in_group("glitch"):
					Global.neko_world.glitch_death()

		if on_floor:
			if is_stair_stepping:
				for i in range(0, get_slide_collision_count()):
					var collision = get_slide_collision(i)
					if collision.get_normal().y > 0.9:
						is_stair_stepping = false
						break
			else:
				for i in range(0, get_slide_collision_count()):
					var collision = get_slide_collision(i)
					var normal = collision.get_normal()

					var dir = Vector2(normal.x, normal.z).normalized()
					var walk_dir = velocity2d.normalized()

					var is_wall_collision = abs(normal.y) < 0.7
					var is_walking_against_wall = abs(dir.dot(walk_dir)) > 0.5
					if not is_wall_collision or not is_walking_against_wall:
						continue

					var start = global_position + Vector3(0, MAX_STEP_HEIGHT, 0) - Vector3(dir.x, 0, dir.y) * $CollisionShape3D.shape.radius
					var end = start - Vector3(dir.x, 0, dir.y) * MIN_STEP_WIDTH
					var height_end = end + Vector3(0, $CollisionShape3D.shape.height + 0.1, 0)
					var space_state = get_world_3d().direct_space_state
					var is_foot_blocked = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
					var is_standing_blocked = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(end, height_end))
					if is_foot_blocked or is_standing_blocked:
						continue

					velocity.y += STEP_UP_FORCE
					is_stair_stepping = true
					break


func idle(delta):
	if Global.in_dialog:
		state = TALKING
		talk(delta)
		return

	if direction.length():
		state = WALKING
		walk(delta)
		return

	if jump_pressed:
		state = JUMPING
		on_floor = false
		jump_pressed = false
		velocity.y = JUMP_VELOCITY
		jump(delta)
		return

	# Handle idle
	velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
	velocity.z = move_toward(velocity.z, 0, STOP_SPEED)
	velocity.y -= gravity * delta
	model.set_velocity(velocity)


func walk(delta):
	if Global.in_dialog:
		state = TALKING
		talk(delta)
		return

	if jump_pressed:
		state = JUMPING
		on_floor = false
		jump_pressed = false
		velocity.y = JUMP_VELOCITY
		jump(delta)
		return

	if not direction:
		state = IDLE
		idle(delta)
		return

	# Handle walk
	velocity.x = direction.x * (WALK_SPEED if sneak else RUN_SPEED)
	velocity.z = direction.z * (WALK_SPEED if sneak else RUN_SPEED)
	velocity.y -= gravity * delta
	model.set_velocity(velocity)


func jump(delta):
	if on_floor:
		state = WALKING
		walk(delta)
		return

	if jump_pressed:
		state = FLYING
		fly(delta, true)
		return

	# Handle jump
	if direction:
		velocity.x += direction.x * (WALK_SPEED if sneak else RUN_SPEED) * WALK_AIR_SPEED_MULTIPLIER
		velocity.z += direction.z * (WALK_SPEED if sneak else RUN_SPEED) * WALK_AIR_SPEED_MULTIPLIER
	velocity.x *= pow(FLIGHT_DRAG_HORIZONTAL, delta)
	velocity.z *= pow(FLIGHT_DRAG_HORIZONTAL, delta)
	velocity.y -= (slowfall_gravity if jump_held else gravity) * delta


func fly(delta, first_frame: bool):
	_visualize_flight(delta, true)
	if on_floor:
		_visualize_flight(delta, false)
		flight_stroke_timer = 0
		flight_strokes = flight_strokes_max
		state = WALKING
		walk(delta)
		return

	if (jump_pressed && flight_strokes > 0 && flight_stroke_timer <= 0) or first_frame:
		flight_strokes -= 1
		velocity.y = FLIGHT_START_VELOCITY_UP if first_frame else FLIGHT_VELOCITY_UP
		velocity.x = FLIGHT_VELOCITY_FORWARD * direction.x
		velocity.z = FLIGHT_VELOCITY_FORWARD * direction.z
		flight_stroke_timer = flight_stroke_timer_first if first_frame else flight_stroke_timer_max
		if not first_frame:
			model.flap_wings()
	else:
		velocity.y -= (flight_gravity if jump_held else gravity) * delta
		velocity.y *= pow(FLIGHT_DRAG_VERTICAL, delta)
		flight_stroke_timer -= delta

	if direction:
		velocity.x += direction.x * (WALK_SPEED if sneak else RUN_SPEED) * FLYING_AIR_SPEED_MULTIPLIER
		velocity.z += direction.z * (WALK_SPEED if sneak else RUN_SPEED) * FLYING_AIR_SPEED_MULTIPLIER

	velocity.x *= pow(FLIGHT_DRAG_HORIZONTAL, delta)
	velocity.z *= pow(FLIGHT_DRAG_HORIZONTAL, delta)


func talk(delta):
	if not Global.in_dialog:
		state = IDLE
		idle(delta)
		return

	velocity = Vector3(0, 0, 0)
	model.set_velocity(velocity)

	# Ideally, we should make the character turn to face the npc
	# being talked to here

var _animating_oob = false
func animate_oob():
	if _animating_oob:
		return
	_animating_oob = true
	SFX.play(preload("res://sfx/falldown.wav"))
	await SceneSwitcher.fade_to_black()
	Global.respawn_scene()
	await SceneSwitcher.unfade_from_black()
	_animating_oob = false

