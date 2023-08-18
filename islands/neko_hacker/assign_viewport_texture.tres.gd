extends GeometryInstance3D

var setup = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var m = (self as GeometryInstance3D).material.duplicate()
	m.set_shader_parameter("viewport", get_viewport().get_texture())
	material_override = m

func _process(delta):
	pass
