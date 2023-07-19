extends CharacterBody3D

@export var camera: Node3D
@export var dialogBox: Control
@export var player: Node3D
@export var characterName = "npc-1"

var dialog_triggered = false

func _physics_process(delta):
	# Trigger some dialog when player is near the NPC
	if not dialog_triggered and position.distance_to(player.position) <= 0.5:
		dialog_triggered = true
		dialogBox.trigger_dialog(characterName, "greet")
