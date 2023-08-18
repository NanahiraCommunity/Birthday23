extends "res://shared/npc/npc_character.gd"

var hand_bone: int

@export var microphone_offset: Vector3 = Vector3.ZERO
@export var microphone_rotation: Vector3 = Vector3.ZERO

@onready var microphone_transform = Transform3D(Basis.from_euler(microphone_rotation * PI / 180.0), microphone_offset)

func _ready():
	super()
	controller.set_holding(true)
	hand_bone = skeleton.find_bone("HandR")

func _process(delta):
	var pose = skeleton.get_bone_global_pose(hand_bone)
	$Microphone.global_transform = skeleton.global_transform * pose * microphone_transform
