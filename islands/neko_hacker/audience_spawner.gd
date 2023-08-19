extends CSGBox3D

@export var rng_seed: int = 1
@export var density: float = 2.0
@export var random_distribution: float = 0.1

@export_range(0.0, 1.0) var z0_probability: float = 1.0
@export_range(0.0, 1.0) var z1_probability: float = 1.0

func _ready():
	visible = false
	var npc_scene = preload("res://islands/neko_hacker/audience_npc.tscn")
	var next_seed = randi()
	var w = size.x * 0.5
	var h = size.z * 0.5
	var max_z = round(size.z * density) + 1
	seed(rng_seed)
	for x in range(0, round(size.x * density) + 1):
		for z in range(0, max_z):
			var prob = lerp(z0_probability, z1_probability, z as float / max_z)
			if randf() > prob:
				continue
			var xl = x + randf_range(-random_distribution * density, random_distribution * density)
			var zl = z + randf_range(-random_distribution * density, random_distribution * density)
			var npc = npc_scene.instantiate()
			npc.transform = transform
			npc.translate(Vector3(xl / density - w, 0, zl / density - h))
			get_parent().add_audience.call_deferred(npc)
	seed(next_seed)
	queue_free()
