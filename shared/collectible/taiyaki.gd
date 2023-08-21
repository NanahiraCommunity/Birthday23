extends "res://shared/collectible/collectible.gd"

var t = 0.0

@export var glow_visibility = 1.0
@export var builtin_billboard = false

func _ready():
	super()
	t = fmod(global_position.x + global_position.z, TAU)
	rotate_y(t)
	$GlowShape.material_override = $GlowShape.material.duplicate()

	var depth = 1.0
	animation = "Collect"

	# billboard just set for editor, we implement our own billboard for animation support
	if not builtin_billboard:
		$Sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED

func _physics_process(delta):
	t += delta
	if t >= TAU:
		t -= TAU

	if not collected:
		var player = get_viewport().get_camera_3d().global_position
		var pos = global_position
		var dir = -atan2(player.z - pos.z, player.x - pos.x) + PI / 2
		global_rotation.y = dir

	$Sprite.position.y = sin(t) * FLOAT_AMPLITUDE

	super(delta)

func set_distance(s: float):
	s = clamp(s * 0.05, 1.0, 1.5)
	$GlowShape.scale = Vector3(s, s, s)
	$GlowShape.material_override.set_shader_parameter("glow_size", s * 0.17);
	$GlowShape.material_override.set_shader_parameter("glow_visibility", glow_visibility);
