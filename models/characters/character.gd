extends Node3D

#var animationPlayer: AnimationPlayer

const VELOCITY_SCALE = 2.0

var last_velocity = Vector3.ZERO

func _ready():
	var scene = preload("res://models/characters/messenger/messenger_papercraft.tscn")
	var instance = scene.instantiate()
	instance.get_node("Armature/Skeleton3D/MessengerPapercraft").reparent($Armature/Skeleton3D, false)

func _process(delta):
	pass

func set_flight(flying: bool):
	if flying:
		$AnimationTree["parameters/playback"].travel("Fly")
	else:
		set_velocity(last_velocity)

func set_velocity(velocity: Vector3):
	last_velocity = velocity
	var v = Vector3(velocity.x, 0, velocity.z).length() * VELOCITY_SCALE
	if v > 0.01:
		var speed = clamp(0.75, 4, v)
		var blend = clamp(0.2, 1, v)
		$AnimationTree["parameters/playback"].travel("Walk")
		$AnimationTree.set("parameters/Walk/Blend2/blend_amount", blend);
		$AnimationTree["parameters/Walk/TimeScale/scale"] = speed
	else:
		$AnimationTree["parameters/playback"].travel("Idle")
		$AnimationTree["parameters/Walk/TimeScale/scale"] = 1.0
