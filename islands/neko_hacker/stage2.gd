extends Node3D

var world
var started = false

func start(_world):
	world = _world
	started = false # since we respawned
	var q = Global.in_quest("stage2_squash_bugs")
	if q:
		start_death_timer(q)
	else:
		Global.active_quests_changed.connect(_recheck_quests)

func _recheck_quests():
	var q = Global.in_quest("stage2_squash_bugs")
	if q:
		start_death_timer(q)
		Global.active_quests_changed.disconnect(_recheck_quests)

func _finished():
	world.abort_countdown_death()
	Global.active_quests_changed.disconnect(_recheck_quests)

func start_death_timer(quest):
	while quest.collected == 0:
		await quest.updated

	if started or quest.done:
		return
	started = true

	quest.finished.connect(_finished)

	if has_node("ConcertStage2/Glitches/RestrictArea"):
		$ConcertStage2/Glitches/RestrictArea.queue_free()

	if Global.did_complete_quest("stage2_squash_bugs"):
		world.abort_countdown_death()
		return

	var bgm = $BGM
	if bgm:
		Global.UI.switch_bgm(bgm.stream)
	world.countdown_death(70.0 + world.timeout_deaths * 5.0)
