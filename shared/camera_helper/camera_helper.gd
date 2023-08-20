## Makes the camera fade to the origin of this node, while inside CollisionAreas that can be added as children

extends Area3D
class_name CameraHelper

@export var smoothing = 0.9

var bound = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(player_entered)
	body_exited.connect(player_exited)

func player_entered(body: Node3D):
	if body == Global.player:
		bound = true

func player_exited(body: Node3D):
	if body == Global.player:
		bound = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if bound:
		var camera = get_window().get_camera_3d()
		var t = global_position
		camera.camera_position.x = (camera.camera_position.x - t.x) * pow(1.0 - smoothing, delta) + t.x
		camera.camera_position.z = (camera.camera_position.z - t.z) * pow(1.0 - smoothing, delta) + t.z

