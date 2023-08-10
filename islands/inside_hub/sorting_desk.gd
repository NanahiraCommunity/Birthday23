extends MeshInstance3D

@export var cart: Node3D
@export var start_letters: int = 0
@export var start_packages: int = 0
@export var orphan_letters: Node3D

enum Process
{
	NONE,
	LETTERS,
	PACKAGES,
	MIXED
}


@export var process = Process.NONE

func is_mixed():
	return process == Process.MIXED

func is_letters_only():
	return process == Process.LETTERS

func is_packages_only():
	return process == Process.PACKAGES

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("tables")
	var letter_scene = preload("res://shared/letter/letter.tscn")
	var package_scene = preload("res://shared/packages/package.tscn")

	var letters = start_letters
	var packages = start_packages

	for i in range(start_letters + start_packages):
		var copy: RigidBody3D = null
		if letters > 0 and packages > 0:
			if randi_range(0, 1) == 0:
				copy = letter_scene.instantiate()
				letters -= 1
			else:
				copy = package_scene.instantiate()
				packages -= 1
		elif letters > 0:
			copy = letter_scene.instantiate()
			letters -= 1
		else:
			copy = package_scene.instantiate()
			packages -= 1
		$Letters.add_child(copy)
		copy.visible = true
		copy.rotation = Vector3(0, randfn(0.0, 0.15) * deg_to_rad(45), 0)
		copy.global_position = $LetterArea.global_position
		copy.position += Vector3(randfn(0.0, 0.15) * 0.2, randfn(0.0, 0.15) * 0.15, randfn(0.0, 0.15) * 0.9)

func get_post_item(npc):
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
		body.desk = self

func _on_cart_area_body_exited(body):
	if body == cart:
		cart.desk = null
		cart = null

func _on_letter_area_body_exited(body):
	if body in $Letters.get_children():
		body.reparent.call_deferred(orphan_letters)

func _on_letter_area_body_entered(body: Node3D):
	if body.is_in_group("post_items") and not body.is_in_group("ignore"):
		body.add_to_group("ignore")
		_reparent_to_letters.call_deferred(body)

func _reparent_to_letters(body: Node3D):
	body.reparent($Letters)
	body.remove_from_group("ignore")

func grab_letter(letter):
	letter.freeze = true
	letter.add_to_group("ignore")
	letter.reparent(orphan_letters)
	await letter.throw_towards($LetterArea/CollisionShape3D)
	_reparent_to_letters(letter)
	letter.freeze = false
