extends Area3D

@export var camera: Node3D

const SMOOTHING = 0.9

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
		var t = $CollisionShape3D.global_position
		camera.camera_position.x = (camera.camera_position.x - t.x) * pow(1.0 - SMOOTHING, delta) + t.x
		camera.camera_position.z = (camera.camera_position.z - t.z) * pow(1.0 - SMOOTHING, delta) + t.z
