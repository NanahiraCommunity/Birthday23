extends Node3D

func _ready():
	add_to_group("audience")

func get_body():
	return $GenericNpc

func get_hands():
	return $GenericNpcHands

func corrupt(viewport):
	$StaticBody3D.queue_free()
	var m = preload("res://islands/neko_hacker/glitch_material.tres").duplicate()
	m.set_shader_parameter("viewport", viewport.get_texture())
	$GenericNpc.set_surface_override_material(0, m)
	$GenericNpcHands.set_surface_override_material(0, m)
