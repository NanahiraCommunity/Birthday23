extends "res://shared/collectible/collectible.gd"

@export var glow_visibility = 1.0

func _ready():
	super()
	rotate_y(fmod(global_position.x + global_position.z, TAU))
	$GlowShape.material_override = $GlowShape.material.duplicate()

	animation = "Collect"

func _physics_process(delta):
	rotate_y(delta * ROTATE_SPEED)
	super(delta)

func set_distance(s: float):
	s = clamp(s * 0.05, 1.0, 1.5)
	$GlowShape.scale = Vector3(s, s, s)
	$GlowShape.material_override.set_shader_parameter("glow_size", s * 0.17);
	$GlowShape.material_override.set_shader_parameter("glow_visibility", glow_visibility);
