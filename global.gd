extends Node

var player: CharacterBody3D
var in_dialog: bool = false
var neko_world_reset_count = 0

func _ready():
	pass

func _process(delta):
	pass

func give_kassan_letter():
	neko_world_reset_count += 1
	print("Kassan has been given the letter %s times" % neko_world_reset_count)
	get_tree().reload_current_scene()
