extends CharacterBody3D

const C = preload("res://models/characters/character.gd")

@export_file("*.dialogue") var dialog_path: String
@export var dialog_entry: String = "start"
@export var lookat_player: bool = true
@export var dynamic_collision: bool = false
@export var hide_quest_indicator: bool = false
@export var interact_point: Marker3D = null
@export var animation_entry: String
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

var controller: Node3D:
	get:
		return $NanahiraPapercraft

func _ready():
	if dynamic_collision:
		$StaticCollision.disabled = true
		$DynamicCollision.disabled = false

func _input(event):
	if event.is_action_pressed("interact") and can_talk:
		Global.current_npc = self
		Global.UI.DialogBox.trigger_dialog(dialog_path, dialog_entry)
		get_viewport().set_input_as_handled()

func _on_child_order_changed():
	if controller and animation_entry:
		controller.set_movement_animation(animation_entry)

func _process(delta):
	var direction: Vector3
	if interact_point == null:
		direction = skeleton.global_position - Global.player.global_position
	else:
		direction = interact_point.global_position - Global.player.global_position
	var distance_squared = direction.length_squared()

	$DialogIndicator.visible = (dialog_path
		and dialog_entry
		and not Global.in_ui
		and distance_squared < INDICATOR_MAX_DISTANCE * INDICATOR_MAX_DISTANCE)
	$DialogIndicator.modulate = Color(1, 1, 1, 1) if can_talk else Color(1, 1, 1, 0.5)

	# Trigger some dialog when player is near the NPC
	if $DialogIndicator.visible and distance_squared <= INTERACT_DISTANCE * INTERACT_DISTANCE:
		can_talk = true
	else:
		can_talk = false

	if hide_quest_indicator:
		$DialogIndicator.visible = false

	if lookat_player:
		var target_angle = head_angle
		keep_head_time -= delta
		if distance_squared <= WATCH_DISTANCE * WATCH_DISTANCE:
			direction = direction.normalized()
			target_angle = fmod(-atan2(direction.x, -direction.z) + 2 * TAU, TAU)
			if target_angle > MAX_HEAD_ROTATION && target_angle < TAU - MAX_HEAD_ROTATION:
				target_angle = 0
				keep_head_time = 0
			else:
				keep_head_time = randf() * 2

		if keep_head_time <= 0:
			target_angle = 0

		var pose = Quaternion(Vector3(0, 1, 0), head_angle)
		var t = skeleton.get_bone_global_pose_no_override(head_bone)
		t.basis = Basis(pose).scaled(t.basis.get_scale())
		head_angle = lerp_angle(head_angle, target_angle, 0.03)
		skeleton.set_bone_global_pose_override(head_bone, t, 1.0, true)
