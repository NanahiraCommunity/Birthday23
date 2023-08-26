extends Node3D

var left_door_animation
var right_door_animation

func _ready():
	left_door_animation = get_node("gate_door2/animation_state")
	right_door_animation = get_node("gate_door/animation_state")
	left_door_animation.play("close")
	right_door_animation.play("close")


# Call this function when the scene is switched
