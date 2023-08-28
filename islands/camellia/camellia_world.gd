extends Node3D

func _ready():
	Global.camellia = self

func _exit_tree():
	Global.camellia = null

func respawn():
	$Player.global_transform = get_node("PlayerSpawn").global_transform
	$Node3D/Camera3D.teleport(get_node("CameraSpawn").global_position)

func unlock_fullflavor():
	if has_node("FestivalArea/Stage/StaticBody3D"):
		get_node("FestivalArea/Stage/StaticBody3D").queue_free()
