extends RigidBody3D

const letter_sprites: Array[Texture2D] = [
	preload("res://shared/letter/letter1.svg"),
	preload("res://shared/letter/letter2.svg"),
	preload("res://shared/letter/letter3.svg"),
]

func _ready():
	$Letter.texture = letter_sprites.pick_random()
