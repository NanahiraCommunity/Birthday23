extends Node3D

func _ready():
	add_to_group("audience")

func get_body():
	return $GenericNpc

func get_hands():
	return $GenericNpcHands
