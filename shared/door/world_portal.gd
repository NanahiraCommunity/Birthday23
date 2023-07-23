extends Area3D

var _next_scene: String
@export_file("*.tscn") var next_scene: String:
	get:
		return _next_scene
	set(value):
		_next_scene = value
		$Sprite3D.modulate = Color(1, 1, 1, 1.0 if value else 0.5)

var inside = false

func _ready():
	$Sprite3D.visible = false
	$Sprite3D.modulate = Color(1, 1, 1, 1.0 if next_scene else 0.5)
	inside = false

func _input(event):
	if event.is_action_pressed("interact") and inside and next_scene:
		get_viewport().set_input_as_handled()
		print("scene change: ", next_scene)
		get_tree().change_scene_to_file(next_scene)

func _on_body_entered(body):
	if body == Global.player:
		$Sprite3D.visible = true
		inside = true

func _on_body_exited(body):
	if body == Global.player:
		$Sprite3D.visible = false
		inside = false
