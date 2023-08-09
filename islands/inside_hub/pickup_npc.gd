extends "res://shared/npc/npc_character.gd"

const SPEED = 1.2
const SPEED_PUSHING = 0.4
const ROTATION_SPEED = 10
const PUSHING_ROTATION_SPEED = 7
const STUCK_TIME_THRESHOLD = 4.0
const STUCK_MARGIN = 0.01
const TARGET_GOAL_DISTANCE = 0.12
const LETTER_PICKUP_DISTANCE = 0.3
const CART_RADIUS = 0.2
const PUSH_DISTANCE = 0.4

@export var orphan_letters: Node3D
@export var room_main: Node3D
@export var cart_destinations: Node3D

@onready var model: Node3D = $NanahiraPapercraft

signal reached_target(reached: bool)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _target: Node3D = null
var timeout: float = 0.0
var navigation_timeout: float = 0.0

var letter_pick_timer: float = 0.0

var stuck_time: float = 0.0
var stuck_pos: Vector3 = Vector3.ZERO
var stuck_retries: int = 0

var pushing_cart: Node3D = null

func _ready():
	super._ready()
	
	$NavigationAgent3D.process_mode = Node.PROCESS_MODE_INHERIT
	NavigationServer3D.agent_set_avoidance_enabled($NavigationAgent3D.get_rid(), true)
	$NavigationAgent3D.avoidance_enabled = true
	$NavigationAgent3D.velocity_computed.connect(Callable(_on_velocity_computed))
	$NavigationAgent3D.navigation_finished.connect(Callable(_navigation_finished.bind(true)))
	
	start_ai.call_deferred()

func set_target(node: Node3D, timeout: float):
	var start = global_position
	var navmap = get_world_3d().navigation_map
	_target = node
	navigation_timeout = timeout
	stuck_time = 0.0
	stuck_retries = 0
	$NavigationAgent3D.target_position = node.global_position

func start_ai():
	while is_inside_tree():
		var desks = get_tree().get_nodes_in_group("tables")
		var carts = get_tree().get_nodes_in_group("carts")

		var has_orphan_letters = false
		for letter in orphan_letters.get_children():
			if letter.is_in_group("throwing"):
				continue
			has_orphan_letters = true
			break
		desks.shuffle()
		desks.sort_custom(func(a, b): a.remaining_items() < b.remaining_items())
		var min_desk_with_cart = null
		for i in range(0, desks.size()):
			if desks[i].cart:
				min_desk_with_cart = desks[i]
				break
		var min_desk_without_cart = null
		for i in range(0, desks.size()):
			if not desks[i].cart:
				min_desk_without_cart = desks[i]
				break

		carts.shuffle()
		var random_filled_in_cart = null
		for i in range(0, carts.size()):
			if carts[i].has_items() and not carts[i].is_sorted():
				random_filled_in_cart = carts[i]
				break
		var random_filled_out_cart = null
		for i in range(0, carts.size()):
			if carts[i].has_items() and carts[i].is_sorted():
				random_filled_out_cart = carts[i]
				break
		var emptied_cart = null
		for i in range(0, carts.size()):
			if carts[i].emptying and not carts[i].has_items():
				emptied_cart = carts[i]
				break

		# TODO: elevator

		# priorities:
		# 0. finished emptying cart
		if emptied_cart:
			await advance_cart(emptied_cart)
		# 1. desk is (almost) empty and has a cart, push to next desk:
		elif min_desk_with_cart and min_desk_with_cart.remaining_items() <= 2:
			await advance_cart(min_desk_with_cart.cart)
		# 2. letters on the floor
		elif has_orphan_letters and letter_pick_timer < 10:
			await pickup_letter()
		# 3. carts with incoming items are available and there is available desks
		elif random_filled_in_cart and min_desk_without_cart:
			await advance_cart(random_filled_in_cart)
		# 4. outgoing carts are ready
		elif random_filled_out_cart:
			await advance_cart(random_filled_out_cart)
		else:
			# just pick up letters if there is nothing to do
			await pickup_letter()

		await get_tree().create_timer(0.5 + randf() * 1.5).timeout

	print("AI finished")

func advance_cart(cart: Node3D):
	print("advance: ", cart.type)
	letter_pick_timer = 0
	set_target(cart.get_node("Handle"), 15.0)
	if not await reached_target:
		return
	var current_markers = []
	var next_markers = []
	match(cart.type):
		Global.CartType.MIXED:
			current_markers = Array(cart_destinations.get_node("Mixed").get_children())
			next_markers = Array(cart_destinations.get_node("TwoSize").get_children())
		Global.CartType.TWO_SIZE:
			current_markers = Array(cart_destinations.get_node("TwoSize").get_children())
			next_markers = Array(cart_destinations.get_node("SortedPackages").get_children())
			next_markers.append_array(cart_destinations.get_node("SortedLetters").get_children())
		Global.CartType.SORTED_PACKAGES:
			current_markers = Array(cart_destinations.get_node("SortedPackages").get_children())
			next_markers = Array(cart_destinations.get_node("Elevator").get_children())
		Global.CartType.SORTED_LETTERS:
			current_markers = Array(cart_destinations.get_node("SortedLetters").get_children())
			next_markers = Array(cart_destinations.get_node("Elevator").get_children())

	var cart_pos = Vector2(cart.global_position.x, cart.global_position.z)
	var current = -2
	for i in range(0, current_markers.size(), 2):
		var marker_pos = Vector2(current_markers[i + 1].global_position.x, current_markers[i + 1].global_position.z)
		if marker_pos.distance_squared_to(cart_pos) <= CART_RADIUS * CART_RADIUS:
			current = i
			break
	if current == -2:
		for i in range(0, next_markers.size(), 2):
			var marker_pos = Vector2(next_markers[i + 1].global_position.x, next_markers[i + 1].global_position.z)
			if marker_pos.distance_squared_to(cart_pos) <= CART_RADIUS * CART_RADIUS:
				current = current_markers.size() + i
				break

	var target_pos: Node3D = null
	var final_pos: Node3D = null
	var next = current + 2
	var empty_next = false
	while true:
		if next < current_markers.size():
			if cart_pos_available(current_markers[next + 1].global_position):
				target_pos = current_markers[next]
				final_pos = current_markers[next + 1]
				break
		else:
			var i = next - current_markers.size()
			if i < next_markers.size():
				if cart_pos_available(next_markers[i + 1].global_position):
					target_pos = next_markers[i]
					final_pos = next_markers[i + 1]
					empty_next = true
					break
			else:
				# no available spot, leave
				break
		next += 2

	if target_pos:
		cart.emptying = true
		await push_cart_to(cart, target_pos)
		await push_cart_to(cart, final_pos)
		await get_tree().create_timer(0.5).timeout
		# TODO: cart desk is not accurate
		cart.align_to_desk()
		cart.emptying = empty_next
		if empty_next:
			set_target(cart.get_node("Handle"), 10.0)
			await reached_target
			cart.empty_out()

	letter_pick_timer = 0

func cart_pos_available(position: Vector3):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, position + Vector3(0, 1, 0), 1 << (8 - 1))
	return not space_state.intersect_ray(query)

func push_cart_to(cart, target_pos: Node3D):
	set_target(target_pos, 20.0)
	pushing_cart = cart
	var lookat = Vector3(cart.global_position.x, global_position.y, cart.global_position.z)
	global_transform = global_transform.looking_at(lookat)
	model.transform.origin = Vector3(0, 0, -PUSH_DISTANCE)
	global_position = model.global_position
	model.transform.origin = Vector3(0, 0, PUSH_DISTANCE)
	cart.set_pushing(true)
	$NavigationAgent3D.radius += 0.05 # can't really make it larger, otherwise it doesn't reach the goal
	await reached_target
	pushing_cart = null
	global_position = model.global_position
	model.transform.origin = Vector3.ZERO
	$NavigationAgent3D.radius -= 0.05
	cart.set_pushing(false)

func pickup_letter():
	var closest_letters = Array(orphan_letters.get_children())
	if closest_letters.size() == 0:
		return
	closest_letters.sort_custom(func(a, b): a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
	var letter = closest_letters[0]
	set_target(letter, 5.0)
	var reached = await reached_target
	if reached or letter.global_position.distance_squared_to(global_position) < LETTER_PICKUP_DISTANCE * LETTER_PICKUP_DISTANCE:
		# TODO: pick up letter, put into cart
		orphan_letters.remove_child(letter)
		letter.queue_free()

func _process(delta):
	super._process(delta)
	letter_pick_timer += delta
	if _target:
		navigation_timeout -= delta
		if timeout < 0:
			timeout = 0.7
			set_target(_target, navigation_timeout)
		else:
			timeout -= delta
			
		if navigation_timeout <= 0:
			_navigation_finished(false)
			return
			
		if global_position.distance_squared_to($NavigationAgent3D.get_final_position()) < TARGET_GOAL_DISTANCE * TARGET_GOAL_DISTANCE:
			set_target(_target, navigation_timeout)
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
				if stuck_retries > 3:
					global_position = $NavigationAgent3D.get_final_position() + Vector3(0, 0.3, 0)
					$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)
					_navigation_finished()
				else:
					global_position = $NavigationAgent3D.get_next_path_position() + Vector3(0, 0.5, 0)
					$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)
					stuck_retries += 1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var ai_velocity = velocity

	if pushing_cart:
		pushing_cart.global_transform = global_transform
		pushing_cart.rotate_y(PI)
		#pushing_cart.transition_to(global_position + global_transform.basis * Vector3(0, 0, -PUSH_DISTANCE))
		#ai_velocity += (global_position - pushing_cart.global_position).normalized() * 0.2
		#global_position += (pushing_cart.global_position - global_position) * delta

	var speed = SPEED_PUSHING if pushing_cart else SPEED

	if not $NavigationAgent3D.is_navigation_finished():
		var next: Vector3 = $NavigationAgent3D.get_next_path_position()
		var movement = (next - global_position).normalized() * speed
		ai_velocity.x = movement.x
		ai_velocity.z = movement.z
		$NavigationAgent3D.set_velocity(ai_velocity)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
	model.set_velocity(velocity)
	update_rotation(delta)

func _navigation_finished(reached: bool = true):
	$NavigationAgent3D.target_position = global_position
	_target = null
	reached_target.emit(reached)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func update_rotation(delta):
	# code below copied from player.gd, TODO: abstract this away
	var velocity2d = Vector2(velocity.x, velocity.z)
	if velocity2d.length_squared() > 0.2 * 0.2:
		var target_rotation = Basis(Vector3(0, 1, 0), -atan2(velocity2d.x, -velocity2d.y))
		var rot_speed = PUSHING_ROTATION_SPEED if pushing_cart else ROTATION_SPEED
		global_transform.basis = global_transform.basis.slerp(target_rotation, rot_speed * delta)
