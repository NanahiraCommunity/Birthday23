extends Node3D

var setup = false

@export var from_override = false

func _ready():
	var this = self
	var m = null
	if from_override:
		m = this.get_surface_override_material(0)
	else:
		m = (this.mesh if this is MeshInstance3D else this).material.duplicate()
	m.set_shader_parameter("viewport", get_viewport().get_texture())
	this.material_override = m

	if this.has_method("is_using_collision"):
		assert(this.is_using_collision())
		add_to_group("glitch")
	for child in get_children():
		if child is StaticBody3D or child is CharacterBody3D or child is RigidBody3D:
			child.add_to_group("glitch")
