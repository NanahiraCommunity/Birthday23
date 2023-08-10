extends "res://shared/npc/npc_character.gd"

const SPEED = 1.4
const SPEED_PUSHING = 1.1#0.4
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

var float_target: Node3D = null
var float_timeout: float = 0

func _ready():
	super._ready()

	$NavigationAgent3D.process_mode = Node.PROCESS_MODE_INHERIT
	NavigationServer3D.agent_set_avoidance_enabled($NavigationAgent3D.get_rid(), true)
	$NavigationAgent3D.avoidance_enabled = true
	$NavigationAgent3D.velocity_computed.connect(Callable(_on_velocity_computed))
	$NavigationAgent3D.navigation_finished.connect(Callable(_navigation_finished.bind(true)))

	start_ai.call_deferred()

func set_target(node: Node3D, timeout: float):
	_target = node
	navigation_timeout = timeout
	stuck_time = 0.0
	stuck_retries = 0
	$NavigationAgent3D.target_position = node.global_position if node else global_position

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
			if carts[i].has_items() and not carts[i].desk and not carts[i].is_sorted() and carts[i].functional:
				random_filled_in_cart = carts[i]
				break
		var random_filled_out_cart = null
		for i in range(0, carts.size()):
			if carts[i].has_items() and not carts[i].desk and carts[i].is_sorted() and carts[i].functional:
				random_filled_out_cart = carts[i]
				break
		var emptied_cart = null
		for i in range(0, carts.size()):
			if carts[i].emptying and not carts[i].has_items() and carts[i].functional:
				emptied_cart = carts[i]
				break

		# TODO: elevator
		var succeeded = true

		# priorities:
		# randomly pick up orphaned letters
		if has_orphan_letters and letter_pick_timer < 10 and randf() < 0.3:
			succeeded = await pickup_letter()
		# 0. finished emptying cart
		elif emptied_cart and randf() < (0.8 if emptied_cart.desk else 0.05):
			succeeded = await advance_cart(emptied_cart, true)
		# 1. desk is (almost) empty and has a cart, push to next desk:
		elif min_desk_with_cart and min_desk_with_cart.remaining_items() <= 2 and randf() < 0.8:
			succeeded = await advance_cart(min_desk_with_cart.cart, false)
		# 2. carts with incoming items are available, not at a desk and there is available desks
		elif random_filled_in_cart and min_desk_without_cart and randf() < 0.8:
			succeeded = await advance_cart(random_filled_in_cart, false)
		# 3. letters on the floor
		elif has_orphan_letters and letter_pick_timer < 10 and randf() < 0.8:
			succeeded = await pickup_letter()
		# 4. outgoing carts are ready
		elif random_filled_out_cart and randf() < 0.8:
			succeeded = await advance_cart(random_filled_out_cart, true)
		else:
			# just pick up letters if there is nothing to do and random checks failed
			await pickup_letter()

		await get_tree().create_timer(0.5 + randf() * 1.5 if succeeded else 0.05).timeout

	print("AI finished")

func advance_cart(cart: Node3D, to_idle_pos: bool):
	print("advance: ", cart.type)
	letter_pick_timer = 0
	set_target(cart.get_node("Handle"), 15.0)
	if not await reached_target:
		return false

	const DISCARD = -3
	const ELEVATOR = -2
	const RESET = -1
	const MIXED = 2
	const LETTERS = 4
	const PACKAGES = 6

	var target = 0
	var empty_at_destination = false
	var fallback_idle = false
	var fallback_elevator = false
	var fallback_discard = false

	match(cart.type):
		Global.CartType.MIXED:
			if cart.has_items():
				target = MIXED
				empty_at_destination = true
				# don't discard incoming letters lol
				#fallback_discard = true
			else:
				target = DISCARD
		Global.CartType.TWO_SIZE:
			if cart.has_letters():
				target = LETTERS
				empty_at_destination = true
				fallback_idle = true
			elif cart.has_packages():
				target = PACKAGES
				empty_at_destination = true
				fallback_idle = true
			elif to_idle_pos:
				target = RESET
			else:
				target = MIXED
				fallback_idle = true
		Global.CartType.SORTED_PACKAGES:
			if to_idle_pos:
				target = ELEVATOR if cart.has_items() else RESET
			else:
				target = PACKAGES
				fallback_elevator = true
		Global.CartType.SORTED_LETTERS:
			if to_idle_pos:
				target = ELEVATOR if cart.has_items() else RESET
			else:
				target = LETTERS
				fallback_elevator = true

	if target == 0:
		return false

	var markers = []

	if target == ELEVATOR:
		markers = Array(cart_destinations.get_node("Elevator").get_children())
	elif target == RESET:
		markers = Array(cart_destinations.get_node("Idle").get_children())
	elif target == DISCARD:
		markers = Array(cart_destinations.get_node("Discard").get_children())
	elif target == MIXED:
		markers = get_table_markers(func(t): return t.is_mixed() and (empty_at_destination or t.remaining_items() > 0))
	elif target == LETTERS:
		markers = get_table_markers(func(t): return t.is_letters_only() and (empty_at_destination or t.remaining_items() > 0))
	elif target == PACKAGES:
		markers = get_table_markers(func(t): return t.is_packages_only() and (empty_at_destination or t.remaining_items() > 0))

	var next = _find_available_cart_pos(markers)
	if next == -1:
		if fallback_idle and target != RESET:
			markers = Array(cart_destinations.get_node("Idle").get_children())
			target = RESET
		if fallback_elevator and target != ELEVATOR:
			markers = Array(cart_destinations.get_node("Elevator").get_children())
			target = ELEVATOR
		if fallback_discard and target != DISCARD:
			markers = Array(cart_destinations.get_node("Discard").get_children())
			target = DISCARD
		next = _find_available_cart_pos(markers)

	if next != -1:
		var target_pos = markers[next]
		var final_pos = markers[next + 1]

		cart.emptying = true
		await push_cart_to(cart, target_pos)
		if target == ELEVATOR or target == DISCARD:
			await float_cart_to(cart, final_pos)
		else:
			if not await push_cart_to(cart, final_pos):
				return false
		await get_tree().create_timer(0.5).timeout
		cart.emptying = empty_at_destination
		if empty_at_destination:
			# TODO: cart desk is not accurate
			if not cart.align_to_desk():
				return false
			set_target(cart.get_node("Handle"), 10.0)
			await reached_target
			cart.empty_out()
		else:
			# optional, not required success
			cart.align_to_desk()

		if target == DISCARD:
			cart.queue_free()
		elif target == RESET:
			cart.emptying = false
		elif target == ELEVATOR:
			cart.emptying = false
			cart.set_functional(false)
			cart.reparent(room_main.get_node("Lift"))
			await float_to(cart_destinations.get_node("Elevator/Marker3D"), 3.0)
		elif empty_at_destination and not to_idle_pos:
			# immediately queue idling
			await get_tree().create_timer(0.3).timeout
			return await advance_cart(cart, true)

	letter_pick_timer = 0

	return next != -1

func get_table_markers(filter_dg: Callable):
	var markers = []
	for table in room_main.get_children():
		if table.is_in_group("tables"):
			var filter_res = filter_dg.call(table)
			if filter_res:
				markers.append(table.get_node("OrientationDestination"))
				markers.append(table.get_node("CartDestination"))
	return markers

func _find_available_cart_pos(list, start = 0) -> int:
	var next = start
	while next < list.size():
		if cart_pos_available(list[next + 1].global_position):
			return next
		next += 2
	return -1

func cart_pos_available(position: Vector3):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, position + Vector3(0, 1, 0), 1 << (8 - 1))
	return not space_state.intersect_ray(query)

func push_cart_to(cart, target_pos: Node3D):
	pushing_cart = cart
	cart.set_pushing(true)
	set_target(target_pos, 20.0)
	var lookat = Vector3(cart.global_position.x, global_position.y, cart.global_position.z)
	global_transform = global_transform.looking_at(lookat)
	model.transform.origin = Vector3(0, 0, -PUSH_DISTANCE)
	global_position = model.global_position
	model.transform.origin = Vector3(0, 0, PUSH_DISTANCE)
	$NavigationAgent3D.radius += 0.05 # can't really make it larger, otherwise it doesn't reach the goal
	var result = await reached_target
	pushing_cart = null
	global_position = model.global_position
	model.transform.origin = Vector3.ZERO
	$NavigationAgent3D.radius -= 0.05
	cart.set_pushing(false)
	return result

func float_cart_to(cart, target: Node3D):
	pushing_cart = cart
	cart.set_pushing(true)
	set_target(null, 1.0)
	velocity = Vector3.ZERO
	$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)
	var lookat = Vector3(cart.global_position.x, global_position.y, cart.global_position.z)
	global_transform = global_transform.looking_at(lookat)
	model.transform.origin = Vector3(0, 0, -PUSH_DISTANCE)
	global_position = model.global_position
	model.transform.origin = Vector3(0, 0, PUSH_DISTANCE)
	await float_to(target, 6.0)
	_physics_process(0)
	pushing_cart = null
	global_position = model.global_position
	model.transform.origin = Vector3.ZERO
	cart.set_pushing(false)

func float_to(target: Node3D, timeout: float):
	# TODO: floating / modifying velocity is super buggy and I can't figure out why
	float_target = target
	float_timeout = timeout
	await reached_target
	global_position = target.global_position
	velocity = Vector3.ZERO
	$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)

func pickup_letter():
	var closest_letters = Array(orphan_letters.get_children())
	if closest_letters.size() == 0:
		return false
	closest_letters.sort_custom(func(a, b): a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
	var letter = closest_letters[0]
	set_target(letter, 5.0)
	var reached = await reached_target
	if reached or letter.global_position.distance_squared_to(global_position) < LETTER_PICKUP_DISTANCE * LETTER_PICKUP_DISTANCE:
		# TODO: pick up letter, put into cart
		orphan_letters.remove_child(letter)
		letter.queue_free()
		return true
	else:
		return false

func _process(delta):
	super._process(delta)
	letter_pick_timer += delta
	if _target and not float_target:
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

	if float_target:
		if global_position.distance_squared_to(float_target.global_position) < TARGET_GOAL_DISTANCE * TARGET_GOAL_DISTANCE:
			_navigation_finished()
			float_target = null
			set_target(null, 1.0)
			$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)
		else:
			var movement = (float_target.global_position - global_position).normalized() * speed
			velocity.x = movement.x
			velocity.z = movement.z
			# TODO: move_and_slide doesn't always work properly here?!
			move_and_slide()

			float_timeout -= delta
			if float_timeout < 0:
				_navigation_finished(false)
				float_target = null
				set_target(null, 1.0)
				$NavigationAgent3D.set_velocity_forced(Vector3.ZERO)
	elif not $NavigationAgent3D.is_navigation_finished():
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
