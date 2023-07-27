extends MeshInstance3D

var npc: CharacterBody3D
var animations: AnimationTree

@export var desk: Node3D

var pick_timeout = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pick_timeout += randf()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if npc:
		if not desk:
			push_warning("stool without desk!", self)
			return
		if not desk.cart:
			# print("no cart")
			return
		var area = desk.cart.get_target_area(true)
		if not area:
			# print("no target area")
			return
		pick_timeout -= delta
		if pick_timeout < 0:
			var letter: RigidBody3D = desk.get_letter(npc)
			if letter:
				animations["parameters/playback"].travel("Sit-throw")
				_animate_letter(letter, area)
			pick_timeout = randf_range(1.0, 3.0)

func _animate_letter(letter: RigidBody3D, area: CollisionShape3D):
	letter.collision_layer = 0
	letter.collision_mask = 1
	var p = Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))
	letter.apply_impulse(Vector3(0.0, 0.05, 0.0), p)
	await get_tree().create_timer(0.1).timeout
	await _fly_to(letter, area)
	letter.collision_layer = 2
	letter.collision_mask = 3

func _fly_to(letter, area: CollisionShape3D):
	if not area.shape is BoxShape3D:
		push_error("invalid area, only supports BoxShape3D")
		return
	var shape: BoxShape3D = area.shape
	#var t = area.global_transform
	#var position_min = t.translated_local(-shape.size)
	#var position_max = t.translated_local( shape.size)
	var tween = create_tween()
	var from = letter.global_position
	var to = area.global_position
	var distance = Vector2(from.x, from.z).distance_to(Vector2(to.x, to.z))
	var time = distance * 1.5
	tween.tween_method(_position_tween.bind(letter, from, to, distance), 0.0, 1.0, time)
	await tween.finished

func _position_tween(t: float, letter: Node3D, from: Vector3, to: Vector3, distance: float):
	var p = from.lerp(to, t)
	var max_h = max(from.y, to.y) + distance * 0.5
	if t < 0.5:
		t = t * 2
		p.y = max_h - pow(1.0 - t, 2) * (max_h - from.y)
	else:
		t = (t - 0.5) * 2
		t = 1.0 - t
		p.y = max_h - pow(1.0 - t, 2) * (max_h - to.y)
	letter.global_position = p

func _on_child_order_changed():
	npc = null
	animations = null

	for child in get_children(false):
		if child is CharacterBody3D:
			npc = child
			npc.lookat_player = false
			animations = npc.get_node("NanahiraPapercraft/AnimationTree")

			npc.position = Vector3(0.05, 0.2, 0)
			npc.basis = Basis(Vector3(0, 1, 0), deg_to_rad(-90))
			animations["parameters/playback"].travel("Sit")
