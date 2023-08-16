extends Node3D

@onready var scene_switcher = get_node("/root/SceneSwitcher")

# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractArea/Sprite3D.visible = false


func _input(event):
	if event.is_action_pressed("interact") and $InteractArea/Sprite3D.visible:
		get_viewport().set_input_as_handled()
		$InteractArea/Sprite3D.visible = false
		Global.current_npc = self
		Global.UI.DialogBox.trigger_dialog("res://shared/quickwarp/quickwarp.dialogue", "start")
		await Global.UI.DialogBox.picked_selection
		$InteractArea/Sprite3D.visible = true
		

func _on_interact_area_body_entered(body):
	if body == Global.player:
		$InteractArea/Sprite3D.visible = true


func _on_interact_area_body_exited(body):
	if body == Global.player:
		$InteractArea/Sprite3D.visible = false

func warp(scene_path: String):
	var scene = load(scene_path)
	scene_switcher.switch_scene(scene)
