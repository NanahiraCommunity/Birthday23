extends CharacterBody3D

const C = preload("res://models/characters/character.gd")

@export var camera: Node3D
@export var dialog_box: Control
@export_file("*.dialogue") var dialog_path: String
@export var dialog_entry: String = "start"
@export var lookat_player: bool = true
@export var dynamic_collision: bool = false
@export var character: C.Character:
	get:
		if not $NanahiraPapercraft:
			return C.Character.NANAHIRA
		return $NanahiraPapercraft.character
	set(value):
		if not $NanahiraPapercraft:
			await ready
		$NanahiraPapercraft.character = value

@onready var skeleton: Skeleton3D = get_node("NanahiraPapercraft/Armature/Skeleton3D")
@onready var head_bone: int = skeleton.find_bone("Head")

const INTERACT_DISTANCE = 0.5
const WATCH_DISTANCE = 1.25
const INDICATOR_MAX_DISTANCE = 2.0
const MAX_HEAD_ROTATION = deg_to_rad(60)

var dialog_triggered = false
var head_angle = 0
var keep_head_time = 0
var can_talk = false

func _ready():
	if dynamic_collision:
		$StaticCollision.disabled = true
		$DynamicCollision.disabled = false

func _input(event):
	if event.is_action_pressed("interact") and can_talk:
		dialog_box.trigger_dialog(dialog_path, dialog_entry)
		get_viewport().set_input_as_handled()

func _process(delta):
	var direction = global_position - Global.player.global_position
	var distance_squared = direction.length_squared()

	$DialogIndicator.visible = (dialog_path and dialog_entry and not Global.in_dialog
		and distance_squared < INDICATOR_MAX_DISTANCE * INDICATOR_MAX_DISTANCE)
	$DialogIndicator.modulate = Color(1, 1, 1, 1) if can_talk else Color(1, 1, 1, 0.5)

	# Trigger some dialog when player is near the NPC
	if $DialogIndicator.visible and distance_squared <= INTERACT_DISTANCE * INTERACT_DISTANCE:
		can_talk = true
	else:
		can_talk = false

	if lookat_player:
		var target_angle = head_angle
		keep_head_time -= delta
		if distance_squared <= WATCH_DISTANCE * WATCH_DISTANCE:
			direction = direction.normalized()
			target_angle = fmod(-atan2(-direction.x, direction.z) + 2 * TAU, TAU)
			if target_angle > MAX_HEAD_ROTATION && target_angle < TAU - MAX_HEAD_ROTATION:
				target_angle = 0
				keep_head_time = 0
			else:
				keep_head_time = randf() * 2

		if keep_head_time <= 0:
			target_angle = 0

		var pose = Quaternion(Vector3(0, 1, 0), head_angle)
		head_angle = lerp_angle(head_angle, target_angle, 0.03)
		skeleton.set_bone_global_pose_override(head_bone, pose, 1.0, true)
