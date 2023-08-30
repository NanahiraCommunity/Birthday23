extends Node3D

func _on_intro_grab_finished():
	Global.try_end_quest("intro_grab")
	$ElfIntro1.queue_free()
	$ElfIntro2.visible = true
	$ElfIntro2.process_mode = Node.PROCESS_MODE_INHERIT
