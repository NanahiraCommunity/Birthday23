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

func fade_to_black():
	var camera = get_viewport().get_camera_3d()
	player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	material.set_shader_parameter("center", player_pos)
	animator.play("Out")
	visible = true
	await animator.animation_finished

func unfade_from_black(delay: float = 0.0):
	if delay > 0.0 and is_inside_tree():
		await get_tree().create_timer(delay).timeout
	var camera = get_viewport().get_camera_3d()
	if not camera:
		var window = get_viewport().get_window()
		player_pos = Vector2(window.size.x * 0.5, window.size.y * 0.5)
	else:
		player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	material.set_shader_parameter("center", player_pos)
	animator.play("In")
	await animator.animation_finished
	visible = false

func switch_scene(scene):
	var tree = get_tree()
	next_scene = scene
	await fade_to_black()
	var bgm = Global.UI.get_node_or_null("BGM")
	if bgm:
		bgm.reparent(self)
	else:
		bgm = get_node("BGM")
	var next: PackedScene = load(next_scene)
	tree.change_scene_to_packed(next)
	await tree.process_frame # scene is adding now

	var new_bgm = tree.current_scene.get_node_or_null("BGM")
	if new_bgm and new_bgm.stream:
		new_bgm.stop()
		if new_bgm.stream != bgm.stream:
			bgm.stream = new_bgm.stream
			bgm.play()
	else:
		bgm.stop()

	await tree.process_frame # first frame was rendered
	await unfade_from_black()
