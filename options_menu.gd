extends Control

@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.pressed.connect(_back)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Hardcoded because thinking of having the options menu accessable from
# gameplay and when clicking back it will take you there and not to title
func _back():
	get_tree().change_scene_to_file("res://main_menu.tscn")
