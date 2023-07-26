extends RigidBody3D

const letter_sprites: Array[Texture2D] = [
	preload("res://shared/letter/letter1.svg"),
	preload("res://shared/letter/letter2.svg"),
	preload("res://shared/letter/letter3.svg"),
]

func _ready():
	$Letter.texture = letter_sprites.pick_random()

func throw_towards(area: CollisionShape3D):
	self.add_to_group("throwing")
	self.collision_layer = 0
	self.collision_mask = 1
	var p = Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))
	self.apply_impulse(Vector3(0.0, 0.05, 0.0), p)
	await get_tree().create_timer(0.1).timeout
	await _fly_to(area)
	self.collision_layer = 2
	self.collision_mask = 3
	self.remove_from_group("throwing")

func _fly_to(area: CollisionShape3D):
	if not area.shape is BoxShape3D:
		push_error("invalid area, only supports BoxShape3D")
		return
	var shape: BoxShape3D = area.shape
	#var t = area.global_transform
	#var position_min = t.translated_local(-shape.size)
	#var position_max = t.translated_local( shape.size)
	var tween = create_tween()
	var from = self.global_position
	var to = area.global_position
	var distance = Vector2(from.x, from.z).distance_to(Vector2(to.x, to.z))
	var time = distance * 1.5
	tween.tween_method(_position_tween.bind(from, to, distance), 0.0, 1.0, time)
	await tween.finished

func _position_tween(t: float, from: Vector3, to: Vector3, distance: float):
	var p = from.lerp(to, t)
	var max_h = max(from.y, to.y) + distance * 0.5
	if t < 0.5:
		t = t * 2
		p.y = max_h - pow(1.0 - t, 2) * (max_h - from.y)
	else:
		t = (t - 0.5) * 2
		t = 1.0 - t
		p.y = max_h - pow(1.0 - t, 2) * (max_h - to.y)
	self.global_position = p
