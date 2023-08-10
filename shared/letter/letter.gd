extends "res://shared/packages/package.gd"

const letter_sprites: Array[Texture2D] = [
	preload("res://shared/letter/letter1.svg"),
	preload("res://shared/letter/letter2.svg"),
	preload("res://shared/letter/letter3.svg"),
	preload("res://shared/letter/letter4.svg"),
	preload("res://shared/letter/letter5.svg"),
	preload("res://shared/letter/letter6.svg"),
]

func _ready():
	self.add_to_group("post_items")
	self.add_to_group("letters")
	$Letter.texture = letter_sprites.pick_random()

func _physics_process(delta):
	$Letter.global_position = global_position + Vector3(0, 0.01, 0)
