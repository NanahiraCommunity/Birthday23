extends Node3D

const ROTATE_SPEED = 0.9
const FLOAT_SPEED = 1.3
const FLOAT_AMPLITUDE = 0.05

const PICKUP_DISTANCE = 0.3
const Y_MIN = -0.2
const Y_MAX = 0.48

@export var type: Global.Collectible = Global.Collectible.STAMP
@export var value = 1
@export var animation: String
@export var sfx: AudioStream

var uid: String
var grid_name: String
var grid_pos: Vector3i = Vector3i.ZERO
var managed = false

signal picked_up

func _ready():
	if not name.begins_with("@"):
		uid =  get_tree().current_scene.scene_file_path + ">" + String(get_path())
		if uid in Global.collected_dynamics:
			queue_free()
	elif grid_name:
		# signals didn't work with the instantiated stamps on collect, so I just put the code here
		# (deadline time constraint)
		pass
	else:
		assert(managed, "attempted to instantiate a collectible without managing its lifecycle")
		# make sure you set managed to true, and with that also check globally
		# if the collectible has already been picked up / avoid double spawning

var collected = false
func _physics_process(delta):
	var player = Global.player.global_position
	var pos = global_position
	var dx = pos.x - player.x;
	var dz = pos.z - player.z;
	var d = dx * dx + dz * dz

	set_distance(d)

	if not collected and d < PICKUP_DISTANCE * PICKUP_DISTANCE:
		var min_player = player.y + Y_MIN
		var max_player = player.y + Y_MAX
		if not (max_player < pos.y or min_player > pos.y):
			collect()
			return

func set_distance(_d: float):
	# overridable
	pass

func collect():
	picked_up.emit()
	collected = true
	if uid:
		Global.collected_dynamics[uid] = true
	elif grid_name:
		Global.collected_grids[grid_name][grid_pos] = true
	Global.collectibles[type] += value
	if animation:
		if sfx:
			SFX.play(sfx)
		$AnimationPlayer.play(animation)
		await $AnimationPlayer.animation_finished
	queue_free()
