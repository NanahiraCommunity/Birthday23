extends Node3D

#var stage = 0
var stage_idx = 1
var loaded_stage: Node = null
var stages: Array[Node] = []

func _ready():
	Global.neko_world = self
	stages = [
		$Stage1,
		$Stage2
	]
	for stage in stages:
		remove_child(stage)
	reload()

func _exit_tree():
	for stage in stages:
		if stage != loaded_stage:
			# loaded_stage is a child node, so freed automatically
			stage.free()

func reload():
	if loaded_stage:
		loaded_stage.process_mode = Node.PROCESS_MODE_DISABLED
		loaded_stage.visible = false
		remove_child(loaded_stage)

	prepare_stage(stages[stage_idx])

func prepare_stage(stage: Node):
	loaded_stage = stage
	add_child(stage)
	stage.process_mode = Node.PROCESS_MODE_INHERIT
	stage.visible = true

	var bgm = stage.get_node_or_null("BGM")
	if bgm:
		Global.UI.switch_bgm(bgm.stream)

	$Player.global_transform = stage.get_node("PlayerSpawn").global_transform
	$Node3D/Camera3D.teleport(stage.get_node("CameraSpawn").global_position)

func give_letter():
	stage_idx += 1
	reload()
