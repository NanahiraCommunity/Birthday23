extends ColorRect

@onready var animator = $AnimationPlayer

var next_scene
var player_pos

const HEAD_OFFSET = Vector3(0, 0.15, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("jump"):
#		switch_scene("some")


func switch_scene(scene):
	var camera = get_viewport().get_camera_3d()
	next_scene = scene
	player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	material.set_shader_parameter("center", player_pos)
	animator.play("Out")
	visible = true
	await animator.animation_finished
	var bgm = Global.UI.get_node_or_null("BGM")
	if bgm:
		bgm.reparent(self)
	else:
		bgm = get_node("BGM")
	var next: PackedScene = load(next_scene)
	get_tree().change_scene_to_packed(next)
	await get_tree().process_frame # scene is adding now

	var new_bgm = get_tree().current_scene.get_node_or_null("BGM")
	if new_bgm and new_bgm.stream:
		new_bgm.stop()
		if new_bgm.stream != bgm.stream:
			bgm.stream = new_bgm.stream
			bgm.play()
	else:
		bgm.stop()

	await get_tree().process_frame # first frame was rendered
	camera = get_viewport().get_camera_3d()
	player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	material.set_shader_parameter("center", player_pos)
	animator.play("In")
	await animator.animation_finished
	visible = false
