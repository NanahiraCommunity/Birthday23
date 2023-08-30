extends Area3D

func _ready():
	body_entered.connect(_body_entered)

func _body_entered(body):
	if body == Global.player:
		get_tree().current_scene.get_node("PlayerSpawn").global_transform = global_transform
		get_tree().current_scene.get_node("CameraSpawn").global_position = get_viewport().get_camera_3d().global_position
