extends CharacterBody3D

@export var camera: Node3D
@export var dialog_box: Control
@export var player: Node3D
@export var character_name = "npc-1"

var dialog_triggered = false

func _physics_process(delta):
	# Trigger some dialog when player is near the NPC
	if not dialog_triggered and position.distance_to(player.position) <= 0.5:
		dialog_triggered = true
		dialog_box.trigger_dialog(character_name, "greet")
