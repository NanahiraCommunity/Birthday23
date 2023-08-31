extends Node3D

func _ready():
	Global.get_quest_node("intro_grab").finished.connect(_on_intro_grab_finished)
	if Global.did_complete_quest("intro_grab"):
		$ElfIntro1.queue_free()
		$ElfIntro2.queue_free()

func _on_intro_grab_finished():
	Global.try_end_quest("intro_grab")
	$ElfIntro1.queue_free()
	$ElfIntro2.visible = true
	$ElfIntro2.process_mode = Node.PROCESS_MODE_INHERIT
