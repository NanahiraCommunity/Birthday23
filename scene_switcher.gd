extends ColorRect

@onready var animator = $AnimationPlayer

var next_scene
var curr_camera
var player_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("jump"):
#		switch_scene("some")


func switch_scene(scene):
	next_scene = scene
	player_pos = curr_camera.unproject_position(curr_camera.target.global_position)
	material.set_shader_parameter("center", player_pos)
	animator.play("Out")
	visible = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Out":
		print("scene change: ", next_scene)
		var next: PackedScene = load(next_scene)
		get_tree().change_scene_to_packed(next)
		player_pos = curr_camera.unproject_position(curr_camera.target.global_position)
		material.set_shader_parameter("center", player_pos)
		animator.play("In")
	else:
		visible = false
