extends Node3D

func _ready():
	Global.in_hub = true
	if Global.first_spawn:
		Global.first_spawn = false
	else:
		$DoorAnimations.play("OpenDoors")
		if has_node("KeepInside"):
			get_node("KeepInside").queue_free()

func _exit_tree():
	Global.in_hub = false
