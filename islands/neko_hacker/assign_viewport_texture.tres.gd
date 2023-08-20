extends Node3D

var setup = false

@export var from_override = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var this = self
	var m = null
	if from_override:
		m = this.get_surface_override_material(0)
	else:
		m = (this.mesh if this is MeshInstance3D else this).material.duplicate()
	m.set_shader_parameter("viewport", get_viewport().get_texture())
	this.material_override = m
