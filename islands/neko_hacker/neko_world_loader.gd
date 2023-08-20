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
	Global.neko_world = null

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

func glitch_death():
	# called from player.gd
	$Player.visible = false
	SFX.play(preload("res://sfx/explosion.wav"))
	$Player.reset()
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	$PlayerExplosion.global_position = $Player.global_position
	$PlayerExplosion.visible = true
	$PlayerExplosion.emitting = true
	await get_tree().create_timer(1.5).timeout
	await SceneSwitcher.fade_to_black()
	reload()
	$Player.visible = true
	$PlayerExplosion.visible = false
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	await SceneSwitcher.unfade_from_black()
