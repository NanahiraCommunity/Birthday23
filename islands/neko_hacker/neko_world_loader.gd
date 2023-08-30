extends Node3D

var stage_idx = 0
var loaded_stage: Node = null
var stages: Array[Node] = []
var timeout_deaths = 0

func _ready():
	Global.neko_world = self
	if Global.is_quest_complete("stage3_simon_says"):
		stage_idx = 3

	stages = [
		$Stage1,
		$Stage2,
		$Stage3,
		$StageComplete
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
	abort_countdown_death()
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

	$Player.global_transform = stage.get_node("PlayerSpawn").global_transform
	$Node3D/Camera3D.teleport(stage.get_node("CameraSpawn").global_position)

	if stage.has_method("start"):
		stage.start(self)

func give_letter():
	stage_idx += 1
	reload()

func glitch_death():
	# called from player.gd
	$Control/Countdown.reset()
	$Player.visible = false
	SFX.play(preload("res://sfx/explosion.wav"))
	$Player.reset()
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	$PlayerExplosion.global_position = $Player.global_position
	$PlayerExplosion.visible = true
	$PlayerExplosion.emitting = true
	if is_inside_tree():
		await get_tree().create_timer(1.5).timeout
	await SceneSwitcher.fade_to_black()
	reload()
	$Player.visible = true
	$PlayerExplosion.visible = false
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	await SceneSwitcher.unfade_from_black()

func abort_countdown_death():
	$Player/Timelimit.emitting = false
	$Player/Timelimit.visible = false
	$Control/Countdown.visible = false
	$Control/Countdown.reset()

func countdown_death(seconds: float):
	$Control/Countdown.visible = true
	$Control/Countdown.set_time(seconds)
	var spawn_particles = seconds >= 10.0
	while $Control/Countdown.remaining_countdown > 0.0:
		if spawn_particles and $Control/Countdown.remaining_countdown < 9.0:
			print("PARTICLES")
			$Player/Timelimit.visible = true
			$Player/Timelimit.emitting = true
			spawn_particles = false
		if not await $Control/Countdown.tick:
			$Player/Timelimit.visible = false
			$Player/Timelimit.emitting = false
			$Control/Countdown.visible = false
			return
	# for particles, and just for fairness as well
	if is_inside_tree():
		await get_tree().create_timer(0.3).timeout
	if $Control/Countdown.aborted:
		$Player/Timelimit.visible = false
		$Player/Timelimit.emitting = false
		$Control/Countdown.visible = false
		return
	glitch_death()
	timeout_deaths += 1
	$Player/Timelimit.visible = false
	$Player/Timelimit.emitting = false
	$Control/Countdown.visible = false
