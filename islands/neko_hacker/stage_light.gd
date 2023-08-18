extends Node3D

@export var player_only_light = true
@export var cone_scale: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if player_only_light:
		$SpotLight3D.visible = false
	if cone_scale != 1.0:
		rescale_cone($Cone1)
		rescale_cone($Cone2)
		rescale_cone($Cone3)
		rescale_cone($Cone4)

func rescale_cone(cone):
	var prev_z = cone.height / 2
	cone.height *= cone_scale
	cone.radius *= cone_scale
	cone.position.z += cone.height / 2 - prev_z

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
