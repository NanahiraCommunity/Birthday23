extends Node3D

func _ready():
	Global.in_hub = true
	if not Global.in_intro:
		$DoorAnimations.play("OpenDoors")
		if has_node("KeepInside"):
			get_node("KeepInside").queue_free()

	Global.get_quest_node("hub_collect_taiyaki").finished.connect(_on_hub_collect_taiyaki_finished)
	Global.get_quest_node("hub_warp").finished.connect(_on_hub_warp_finished)

func _exit_tree():
	Global.in_hub = false


func _on_hub_collect_taiyaki_finished():
	$TaiyakiGirl.hide_quest_indicator = false
	$Quests/hub_collect_taiyaki/SampleTaiyaki.visible = false


func _on_hub_warp_finished():
	Global.try_end_quest("hub_warp")
