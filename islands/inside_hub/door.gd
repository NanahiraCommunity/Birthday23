extends "res://shared/door/world_portal.gd"

@export var locked: bool = true

func _ready():
	if not locked:
		next_scene = "dummy"
	super._ready()

func enter_door():
	if locked:
		return
	print("enter")
