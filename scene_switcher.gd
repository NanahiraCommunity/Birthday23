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


func _on_animation_player_animation_finished(anim_name):
	var camera = get_viewport().get_camera_3d()
	if anim_name == "Out":
		print("scene change: ", next_scene)
		var next: PackedScene = load(next_scene)
		get_tree().change_scene_to_packed(next)
		player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
		material.set_shader_parameter("center", player_pos)
		animator.play("In")
	else:
		visible = false
