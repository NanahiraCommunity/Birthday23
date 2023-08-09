extends Node3D

@onready var scene_switcher = get_node("/root/SceneSwitcher")

var _next_scene: String
@export_file("*.tscn") var next_scene: String:
	get:
		return _next_scene
	set(value):
		_next_scene = value
		if $Sprite3D:
			$Sprite3D.modulate = Color(1, 1, 1, 1.0 if value else 0.5)

var inside = false

func _ready():
	$Sprite3D.visible = false
	$Sprite3D.modulate = Color(1, 1, 1, 1.0 if next_scene else 0.5)
	inside = false

func _input(event):
	if event.is_action_pressed("interact") and inside and next_scene:
		get_viewport().set_input_as_handled()
		enter_door()

func enter_door():
	print("scene change: ", next_scene)
	scene_switcher.switch_scene(next_scene)

func _on_body_entered(body):
	if body == Global.player:
		$Sprite3D.visible = true
		inside = true

func _on_body_exited(body):
	if body == Global.player:
		$Sprite3D.visible = false
		inside = false
