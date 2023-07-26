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
		if desk.cart.emptying:
			# emptying onto desk
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
				_throw_and_notify(letter, area)
			pick_timeout = randf_range(1.0, 3.0)

func _throw_and_notify(letter: Node3D, area):
	await letter.throw_towards(area)
	if desk.cart:
		desk.cart.notify_letter(letter)

func _on_child_order_changed():
	npc = null
	animations = null

	for child in get_children(false):
		if child is CharacterBody3D:
			npc = child
			npc.lookat_player = false
			animations = npc.get_node("nanahira_papercraft/AnimationTree")

			npc.global_position = global_position + Vector3(0.05, 0.2, 0)
			npc.basis = Basis(Vector3(0, 1, 0), deg_to_rad(-90))
			animations["parameters/playback"].travel("Sit")
			break
