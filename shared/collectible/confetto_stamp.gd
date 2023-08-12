extends "res://shared/collectible/collectible.gd"

var t = 0.0
var base_scale = 1.0

@export var color_big: Color

@export var glow_visibility = 1.0

func _ready():
	t = fmod(global_position.x + global_position.z, TAU)
	rotate_y(t)
	$GlowShape.material_override = $GlowShape.material.duplicate()

	var depth = 1.0
	if value == 1:
		base_scale = 0.75
		animation = "CollectSmall"
	elif value == 10:
		base_scale = 1.5
		depth = 2.0
		animation = "CollectBig"
		var m = $Confetto.get_surface_override_material(0).duplicate()
		m.set_shader_parameter("primary", color_big)
		$Confetto.set_surface_override_material(0, m)
		$GlowShape.material_override.set_shader_parameter("glow_color", color_big)
	else:
		assert(false)
	$Confetto.scale = Vector3(base_scale, base_scale, base_scale * depth)

func _physics_process(delta):
	rotate_y(delta * ROTATE_SPEED)
	t += delta * FLOAT_SPEED
	if t > TAU:
		t -= TAU
	$Confetto.position.y = sin(t) * FLOAT_AMPLITUDE

	super(delta)

func set_distance(s: float):
	s = clamp(s * 0.05, 1.0, 1.5) * base_scale
	$GlowShape.scale = Vector3(s, s, s)
	$GlowShape.material_override.set_shader_parameter("glow_size", s * 0.17);
	$GlowShape.material_override.set_shader_parameter("glow_visibility", glow_visibility);
