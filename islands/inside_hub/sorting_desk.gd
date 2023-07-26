extends MeshInstance3D

@export var cart: Node3D
@export var start_letters: int = 0
@export var orphan_letters: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("tables")
	var letter_scene = preload("res://shared/letter/letter.tscn")
	for i in range(start_letters):
		var copy: RigidBody3D = letter_scene.instantiate()
		$Letters.add_child(copy)
		copy.visible = true
		copy.global_rotation = Vector3(0, randfn(0.0, 0.15) * deg_to_rad(45), 0)
		copy.global_position += Vector3(randfn(0.0, 0.15) * 0.2, randfn(0.0, 0.15) * 0.15, randfn(0.0, 0.15) * 0.9)

func get_letter(npc):
	var c = $Letters.get_child_count()
	var n = min(10, c)
	var closest = null
	var closest_dist = 1000000000.0
	var p: Vector3 = npc.global_position
	for child in range(n):
		var letter = $Letters.get_child(randi_range(0, c - 1))
		if not $LetterArea.overlaps_body(letter):
			continue
		var d = p.distance_squared_to(letter.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = letter
	return closest

func remaining_items():
	return $Letters.get_child_count()

func _on_cart_area_body_entered(body: Node3D):
	if body.is_in_group("carts") and not cart:
		cart = body

func _on_cart_area_body_exited(body):
	if body == cart:
		cart = null

func _on_letter_area_body_exited(body):
	if body in $Letters.get_children():
		body.reparent.call_deferred(orphan_letters)

func _on_letter_area_body_entered(body: Node3D):
	if body.has_meta("is_letter") and not body.is_in_group("ignore"):
		body.add_to_group("ignore")
		_reparent_to_letters.call_deferred(body)

func _reparent_to_letters(body: Node3D):
	body.reparent($Letters)
	body.remove_from_group("ignore")
