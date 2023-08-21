extends Node3D

func start(world):
	get_tree().call_group("bugs", "queue_free")
